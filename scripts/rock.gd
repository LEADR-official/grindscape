extends StaticBody2D
## Minable rock — click to mine when in range, 2s cooldown between mines.
## After a random number of mines (1–13), despawns and respawns elsewhere.

signal ore_mined
signal mine_attempted
signal rock_crumbled

const COOLDOWN_MODULATE := Color(0.6, 0.55, 0.5, 1)
const NORMAL_MODULATE := Color(1, 1, 1, 1)
const MIN_MINES_BEFORE_DESPAWN: int = 1
const MAX_MINES_BEFORE_DESPAWN: int = 13
const MIN_RESPAWN_TIME: float = 1.0
const MAX_RESPAWN_TIME: float = 10.0
const ARENA_MARGIN: float = 60.0
const ARENA_WIDTH: float = 1280.0
const ARENA_HEIGHT: float = 720.0

var _on_cooldown: bool = false
var _despawned: bool = false
var _mines_until_despawn: int = 0

@onready var _interaction_area: Area2D = $InteractionArea
@onready var _sprite: Sprite2D = $Sprite2D
@onready var _cooldown_timer: Timer = $CooldownTimer
@onready var _respawn_timer: Timer = $RespawnTimer


func _ready() -> void:
	_interaction_area.input_event.connect(_on_interaction_input_event)
	_cooldown_timer.timeout.connect(_on_cooldown_finished)
	_respawn_timer.timeout.connect(_respawn)
	_roll_mines_until_despawn()


func is_engageable() -> bool:
	return not _despawned


func try_mine(player: CharacterBody2D) -> void:
	# Check if player is in interaction range
	if player not in _interaction_area.get_overlapping_bodies():
		return

	# During cooldown, show idle pose with pickaxe
	if _on_cooldown or _despawned:
		player.play_idle_with_tool("pickaxe")
		return

	# Emit signal to trigger animation and XP via game.gd
	mine_attempted.emit()

	var success_threshold: float = clamp(0.5 + (float(int(Stats.xp)) / 1000.0) * 0.45, 0.5, 0.95)
	var roll := randf()
	print("Mining attempt: roll=%.2f, success_threshold=%.2f" % [roll, success_threshold])

	if roll <= success_threshold:
		ore_mined.emit()
		_mines_until_despawn -= 1
		if _mines_until_despawn <= 0:
			_begin_crumble()
		else:
			_on_cooldown = true
			_sprite.modulate = COOLDOWN_MODULATE
			_cooldown_timer.start()
	else:
		# Failed mine attempt
		_on_cooldown = true
		_cooldown_timer.start()


func _on_interaction_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if _despawned:
		return
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			var player := get_tree().get_first_node_in_group("player") as CharacterBody2D
			if player and player.has_method("engage"):
				player.engage(self, "mine")


func _on_cooldown_finished() -> void:
	_on_cooldown = false
	_sprite.modulate = NORMAL_MODULATE


func _begin_crumble() -> void:
	_on_cooldown = true
	var origin := position
	var tween := create_tween()
	for i in range(4):
		tween.tween_property(self, "position:x", origin.x + 4.0, 0.075)
		tween.tween_property(self, "position:x", origin.x - 4.0, 0.075)
	tween.tween_property(self, "position:x", origin.x, 0.075)
	tween.tween_callback(_despawn)


func _despawn() -> void:
	_despawned = true
	_on_cooldown = false
	rock_crumbled.emit()
	visible = false
	set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
	var wait := randf_range(MIN_RESPAWN_TIME, MAX_RESPAWN_TIME)
	_respawn_timer.wait_time = wait
	_respawn_timer.start()
	print("Rock crumbled! Respawning in %.1fs" % wait)


func _respawn() -> void:
	var new_x := randf_range(ARENA_MARGIN, ARENA_WIDTH - ARENA_MARGIN)
	var new_y := randf_range(ARENA_MARGIN, ARENA_HEIGHT - ARENA_MARGIN)
	global_position = Vector2(new_x, new_y)
	_despawned = false
	_sprite.modulate = NORMAL_MODULATE
	visible = true
	set_deferred("process_mode", Node.PROCESS_MODE_INHERIT)
	_roll_mines_until_despawn()
	print("Rock respawned at ", global_position, " (%d mines until despawn)" % _mines_until_despawn)


func _roll_mines_until_despawn() -> void:
	_mines_until_despawn = randi_range(MIN_MINES_BEFORE_DESPAWN, MAX_MINES_BEFORE_DESPAWN)
