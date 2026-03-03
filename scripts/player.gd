extends CharacterBody2D
## Player controller — click anywhere to move toward that point.
## Has a health pool; emits player_died at zero.

signal player_died
signal health_changed(current: int, maximum: int)

const MOVE_SPEED: float = 200.0
const ARRIVAL_THRESHOLD: float = 2.0
const PIXELS_PER_METER: float = 32.0
const MAX_HEALTH: int = 10

var health: int = MAX_HEALTH
var _target_position: Vector2
var _facing_right: bool = true
var _pending_idle: String = "idle"
var _is_action_playing: bool = false

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	_target_position = position
	health_changed.emit(health, MAX_HEALTH)
	_sprite.animation_finished.connect(_on_animation_finished)
	_sprite.play("idle")


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			_target_position = mb.position
			print("Click at ", mb.position, " → moving from ", position)


func take_damage(amount: int) -> void:
	health = max(health - amount, 0)
	health_changed.emit(health, MAX_HEALTH)
	if health <= 0:
		player_died.emit()


func stop() -> void:
	_target_position = position
	velocity = Vector2.ZERO


func _physics_process(_delta: float) -> void:
	var distance := position.distance_to(_target_position)
	if distance > ARRIVAL_THRESHOLD:
		var direction := position.direction_to(_target_position)
		velocity = direction * MOVE_SPEED

		if direction.x != 0:
			_facing_right = direction.x > 0
			_sprite.flip_h = not _facing_right

		if not _is_action_playing and _sprite.animation != "run":
			_sprite.play("run")

		var pos_before := position
		move_and_slide()
		var moved := position.distance_to(pos_before)
		if moved > 0.0:
			Stats.add_distance_traveled(moved / PIXELS_PER_METER)
	else:
		velocity = Vector2.ZERO
		if not _is_action_playing and _sprite.animation == "run":
			_sprite.play(_pending_idle)


func play_mine_animation(target_position: Vector2) -> void:
	_is_action_playing = true
	_pending_idle = "idle_pickaxe"
	_update_facing_for_target(target_position)
	_sprite.play("mine")


func play_attack_animation(target_position: Vector2) -> void:
	_is_action_playing = true
	_pending_idle = "idle_knife"
	_update_facing_for_target(target_position)
	_sprite.play("attack")


func _update_facing_for_target(target: Vector2) -> void:
	if target.x != position.x:
		_facing_right = target.x > position.x
		_sprite.flip_h = not _facing_right


func _on_animation_finished() -> void:
	if _sprite.animation in ["mine", "attack"]:
		_is_action_playing = false
		_sprite.play(_pending_idle)
