extends CharacterBody2D
## Player controller — click anywhere to move toward that point.
## Has a health pool; emits player_died at zero.

signal player_died
signal health_changed(current: int, maximum: int)

const MOVE_SPEED: float = 150.0
const ARRIVAL_THRESHOLD: float = 2.0
const PIXELS_PER_METER: float = 32.0
const MAX_HEALTH: int = 10
const HEALTH_BAR_WIDTH: float = 32.0

var health: int = MAX_HEALTH
var _target_position: Vector2
var _facing_right: bool = true
var _pending_idle: String = "idle"
var _is_action_playing: bool = false
var _in_combat: bool = false
var _engaged_target: Node2D = null
var _engaged_action: String = ""

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _health_bar: Control = $HealthBar
@onready var _health_fill: ColorRect = $HealthBar/Fill
@onready var _combat_timer: Timer = $CombatTimer
@onready var _attack_sfx: AudioStreamPlayer2D = $AttackSFX
@onready var _take_damage_sfx: AudioStreamPlayer2D = $TakeDamageSFX


func _ready() -> void:
	_target_position = position
	health_changed.emit(health, MAX_HEALTH)
	_sprite.animation_finished.connect(_on_animation_finished)
	_combat_timer.timeout.connect(_on_combat_timer_timeout)
	_sprite.play("idle")
	_health_bar.visible = false
	_update_health_bar()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			disengage()
			_target_position = mb.position


func take_damage(amount: int) -> void:
	health = max(health - amount, 0)
	_take_damage_sfx.play()
	health_changed.emit(health, MAX_HEALTH)
	_in_combat = true
	_health_bar.visible = true
	_combat_timer.start()
	_update_health_bar()
	if health <= 0:
		player_died.emit()


func stop() -> void:
	_target_position = position
	velocity = Vector2.ZERO


func engage(target: Node2D, action: String) -> void:
	_engaged_target = target
	_engaged_action = action
	_target_position = target.global_position


func disengage() -> void:
	_engaged_target = null
	_engaged_action = ""
	_pending_idle = "idle"


func play_attack_sound() -> void:
	_attack_sfx.play()


func _process_engagement() -> void:
	if _engaged_target == null:
		return

	# Check if target is still valid
	if not is_instance_valid(_engaged_target):
		disengage()
		return

	# Check if target is despawned/dead (targets expose is_engageable())
	if _engaged_target.has_method("is_engageable") and not _engaged_target.is_engageable():
		disengage()
		return

	# Track moving targets (e.g., skeleton)
	_target_position = _engaged_target.global_position

	# Only attempt action when not already playing one
	if _is_action_playing:
		return

	# Check if we're in range and can perform action
	if _engaged_action == "mine" and _engaged_target.has_method("try_mine"):
		_engaged_target.try_mine(self)
	elif _engaged_action == "attack" and _engaged_target.has_method("try_attack"):
		_engaged_target.try_attack(self)


func _physics_process(_delta: float) -> void:
	# Process engagement first (updates _target_position for moving targets)
	_process_engagement()

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


func play_idle_with_tool(tool: String) -> void:
	var anim := "idle_pickaxe" if tool == "pickaxe" else "idle_knife"
	_pending_idle = anim
	stop()  # Prevents run animation from overriding later in _physics_process
	if _sprite.animation != anim:
		_sprite.play(anim)


func _update_facing_for_target(target: Vector2) -> void:
	if target.x != position.x:
		_facing_right = target.x > position.x
		_sprite.flip_h = not _facing_right


func _on_animation_finished() -> void:
	if _sprite.animation in ["mine", "attack"]:
		_is_action_playing = false
		# If engaged, the next _process_engagement() call will restart the action
		# Otherwise, return to idle
		if _engaged_target == null:
			_sprite.play(_pending_idle)


func _update_health_bar() -> void:
	var ratio := float(health) / float(MAX_HEALTH)
	_health_fill.size.x = HEALTH_BAR_WIDTH * ratio


func _on_combat_timer_timeout() -> void:
	_in_combat = false
	_health_bar.visible = false
