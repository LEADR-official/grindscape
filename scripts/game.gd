extends Node2D
## Game orchestrator — wires signals between child scenes and Stats.

const ORE_XP_VALUE: float = 3.25
const SKELETON_HIT_XP: float = 2.0
const SKELETON_KILL_XP: float = 7.0
const DAMAGE_PER_HIT: int = 1
const DAMAGE_TAKEN_XP: float = 1.0

@onready var _rock: StaticBody2D = $Rock
@onready var _player: CharacterBody2D = $Player
@onready var _skeleton: CharacterBody2D = $Skeleton
@onready var _game_over_screen: CanvasLayer = $GameOverScreen


func _ready() -> void:
	_rock.mine_attempted.connect(_on_mine_attempted)
	_rock.ore_mined.connect(_on_ore_mined)
	_skeleton.skeleton_hit.connect(_on_skeleton_hit)
	_skeleton.skeleton_killed.connect(_on_skeleton_killed)
	_skeleton.skeleton_attacked_player.connect(_on_skeleton_attacked_player)
	_player.player_died.connect(_on_player_died)


func _on_mine_attempted() -> void:
	_player.play_mine_animation(_rock.global_position)
	_player.stop()


func _on_ore_mined() -> void:
	Stats.add_ore()
	Stats.add_xp(ORE_XP_VALUE)


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


func _on_player_died() -> void:
	get_tree().paused = true
	_game_over_screen.show_game_over()
