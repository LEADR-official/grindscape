extends Node2D
## Game orchestrator — wires signals between child scenes and Stats.

const ORE_XP_VALUE: float = 3.25
const SKELETON_HIT_XP: float = 2.0
const SKELETON_KILL_XP: float = 7.0
const DAMAGE_PER_HIT: int = 1
const DAMAGE_TAKEN_XP: float = 1.0

const SPAWN_MARGIN: float = 60.0

@onready var _rock: StaticBody2D = $Rock
@onready var _player: CharacterBody2D = $Player
@onready var _skeleton: CharacterBody2D = $Skeleton
@onready var _game_over_screen: CanvasLayer = $GameOverScreen
@onready var _grass_layer: TileMapLayer = $GrassLayer
@onready var _game_die_sfx: AudioStreamPlayer = $GameDieSFX


func _ready() -> void:
	_rock.mine_attempted.connect(_on_mine_attempted)
	_rock.ore_mined.connect(_on_ore_mined)
	_skeleton.skeleton_hit.connect(_on_skeleton_hit)
	_skeleton.skeleton_killed.connect(_on_skeleton_killed)
	_skeleton.skeleton_attacked_player.connect(_on_skeleton_attacked_player)
	_player.player_died.connect(_on_player_died)


func get_spawn_bounds() -> Rect2:
	var used_rect := _grass_layer.get_used_rect()
	var tile_size := _grass_layer.tile_set.tile_size
	var origin := Vector2(used_rect.position) * Vector2(tile_size)
	var size := Vector2(used_rect.size) * Vector2(tile_size)
	return Rect2(
		origin.x + SPAWN_MARGIN,
		origin.y + SPAWN_MARGIN,
		size.x - SPAWN_MARGIN * 2,
		size.y - SPAWN_MARGIN * 2
	)


func _on_mine_attempted() -> void:
	_player.play_mine_animation(_rock.global_position)
	_player.stop()


func _on_ore_mined() -> void:
	Stats.add_ore()
	Stats.add_xp(ORE_XP_VALUE)
	_player.disengage()


func _on_skeleton_hit() -> void:
	Stats.add_xp(SKELETON_HIT_XP)
	Stats.add_damage_dealt(1)
	_player.play_attack_animation(_skeleton.global_position)
	_player.stop()


func _on_skeleton_killed() -> void:
	Stats.add_skeleton_kill()
	Stats.add_xp(SKELETON_KILL_XP)


func _on_skeleton_attacked_player() -> void:
	_player.take_damage(DAMAGE_PER_HIT)
	Stats.add_damage_taken(DAMAGE_PER_HIT)
	Stats.add_xp(DAMAGE_TAKEN_XP)


func _process(delta: float) -> void:
	Stats.add_survival_time(delta)


func _format_number(n: int) -> String:
	var s := str(n)
	var result := ""
	var count := 0
	for i in range(s.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			result = "," + result
		result = s[i] + result
		count += 1
	return result


func _on_player_died() -> void:
	get_tree().paused = true
	_game_die_sfx.play()

	var display_name: String = Stats.player_display_name

	# Board configs: [board_type, board_id, value, value_display]
	var boards: Array = [
		{
			"type": 0,  # SCORE
			"board_id": "brd_a313d59c-1fee-487a-98d8-e5f77b466f46",
			"value": Stats.get_score(),
			"value_display": _format_number(int(Stats.get_score())),
		},
		{
			"type": 1,  # ORE
			"board_id": "brd_582a7a2f-0b5b-48ad-be71-f891b1d4ea3e",
			"value": float(Stats.ore_count),
			"value_display": _format_number(Stats.ore_count),
		},
		{
			"type": 2,  # XP
			"board_id": "brd_8fd74728-46e4-4704-8a16-4ac046f48fe5",
			"value": Stats.xp,
			"value_display": _format_number(int(Stats.xp)),
		},
		{
			"type": 3,  # KILLS
			"board_id": "brd_26fd4784-72cc-42b1-bf7d-bbcbad390d27",
			"value": float(Stats.skeleton_kills),
			"value_display": _format_number(Stats.skeleton_kills),
		},
		{
			"type": 4,  # TIME
			"board_id": "brd_c521d944-fd29-4cf9-b427-cc7a684bbaa3",
			"value": Stats.survival_time_seconds,
			"value_display":
			(
				"%d:%02d"
				% [int(Stats.survival_time_seconds) / 60.0, int(Stats.survival_time_seconds) % 60]
			),
		},
		{
			"type": 5,  # ALL-TIME PLAY TIME
			"board_id": "brd_e4850af6-48da-45c4-9d89-926eb8f0c5d5",
			"value": Stats.survival_time_seconds,
		},
		{
			"type": 6,  # ALL-TIME XP
			"board_id": "brd_03e03437-8504-433f-8468-aac2da912b32",
			"value": Stats.xp,
		},
		{
			"type": 7,  # FASTEST DEATH
			"board_id": "brd_ea7c8167-c1d6-442e-85db-376ec959bf5f",
			"value": Stats.survival_time_seconds,
			"value_display":
			(
				"%d:%02d"
				% [int(Stats.survival_time_seconds) / 60.0, int(Stats.survival_time_seconds) % 60]
			),
		},
		{
			"type": 8,  # DPS
			"board_id": "brd_ba478d51-c618-4203-a9ce-42232cabe036",
			"value": Stats.get_dps(),
		},
	]

	# Fetch predicted rank for SCORE board before submission
	var score_board: Dictionary = boards[0]
	var predicted_rank: int = -1
	var predict_result: LeadrResult = await Leadr.get_scores(
		score_board["board_id"], 1, "", "", score_board["value"]
	)
	if predict_result.is_success:
		var page: LeadrPagedResult = predict_result.data
		if not page.is_empty():
			var placeholder_score: LeadrScore = page.first()
			predicted_rank = placeholder_score.rank
	else:
		push_warning("Failed to fetch predicted rank: %s" % predict_result.error.message)

	# Show game over with predicted rank
	_game_over_screen.show_game_over(predicted_rank)

	# Hand off to persistent Stats autoload so submission survives scene change
	Stats.submit_scores_in_background(boards, display_name)
