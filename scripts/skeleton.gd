extends CharacterBody2D
## Skeleton enemy — chases player, can be attacked via click interaction.
## 3 hits to kill, respawns at random location after death.

signal skeleton_hit
signal skeleton_killed
signal skeleton_attacked_player

const CHASE_SPEED: float = 70.0
const ATTACK_RANGE: float = 72.0
const DAMAGE_COOLDOWN: float = 1.5
const HITS_TO_KILL: int = 3
const MIN_RESPAWN_TIME: float = 3.0
const MAX_RESPAWN_TIME: float = 8.0
const ARENA_MARGIN: float = 60.0
const ARENA_WIDTH: float = 1280.0
const ARENA_HEIGHT: float = 720.0
const HEALTH_BAR_WIDTH: float = 32.0

var _hits_remaining: int = HITS_TO_KILL
var _pending_attack: bool = false
var _attack_cooldown: bool = false
var _dead: bool = false
var _in_combat: bool = false
var _damage_ready: bool = true
var _player: CharacterBody2D
var _facing_right: bool = true

@onready var _hit_area: Area2D = $HitArea
@onready var _attack_cooldown_timer: Timer = $AttackCooldownTimer
@onready var _respawn_timer: Timer = $RespawnTimer
@onready var _damage_cooldown_timer: Timer = $DamageCooldownTimer
@onready var _health_bar: Control = $HealthBar
@onready var _health_fill: ColorRect = $HealthBar/Fill
@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	_player = get_tree().get_first_node_in_group("player") as CharacterBody2D
	_hit_area.input_event.connect(_on_hit_area_input_event)
	_hit_area.body_entered.connect(_on_body_entered)
	_attack_cooldown_timer.timeout.connect(_on_attack_cooldown_finished)
	_respawn_timer.timeout.connect(_respawn)
	_damage_cooldown_timer.timeout.connect(_on_damage_cooldown_finished)
	_sprite.animation_finished.connect(_on_animation_finished)
	_health_bar.visible = false
	_update_health_bar()
	_sprite.play("idle")


func _physics_process(_delta: float) -> void:
	if _dead or _player == null:
		return
	var distance := global_position.distance_to(_player.global_position)
	var direction := global_position.direction_to(_player.global_position)

	if direction.x != 0:
		_facing_right = direction.x > 0
		_sprite.flip_h = not _facing_right

	if distance > ATTACK_RANGE:
		velocity = direction * CHASE_SPEED
		var pos_before := global_position
		move_and_slide()
		var moved := global_position.distance_to(pos_before)

		# Check if actually moving or blocked
		if moved > 0.5:
			if _sprite.animation not in ["run", "defend"]:
				_sprite.play("run")
		else:
			if _sprite.animation == "run":
				_sprite.play("idle")
	else:
		velocity = Vector2.ZERO
		if _sprite.animation == "run":
			_sprite.play("idle")
		if _damage_ready:
			_damage_ready = false
			_damage_cooldown_timer.start()
			_sprite.play("attack")
			skeleton_attacked_player.emit()


func _on_hit_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if _attack_cooldown or _dead:
		return
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			_pending_attack = true
			for body in _hit_area.get_overlapping_bodies():
				if body.is_in_group("player"):
					_attack()
					return


func _on_body_entered(body: Node2D) -> void:
	if _pending_attack and not _dead and body.is_in_group("player"):
		_attack()


func _attack() -> void:
	_pending_attack = false
	_attack_cooldown = true
	_in_combat = true
	_health_bar.visible = true
	_attack_cooldown_timer.start()
	_hits_remaining -= 1
	_update_health_bar()
	_sprite.play("defend")
	skeleton_hit.emit()
	if _hits_remaining <= 0:
		skeleton_killed.emit()
		_die()


func _on_attack_cooldown_finished() -> void:
	_attack_cooldown = false
	_in_combat = false
	_health_bar.visible = false


func _on_damage_cooldown_finished() -> void:
	_damage_ready = true


func _die() -> void:
	_dead = true
	_pending_attack = false
	_attack_cooldown = false
	_in_combat = false
	_health_bar.visible = false

	# Death animation: idle pose, paused
	_sprite.play("idle")
	_sprite.pause()

	# Rotate to fall backwards (direction based on facing)
	var rotation_amount: float = deg_to_rad(90.0) if _sprite.flip_h else deg_to_rad(-90.0)

	var tween := create_tween()
	tween.finished.connect(_finish_death)
	tween.set_parallel(true)

	# Rotate with bounce easing
	(
		tween
		. tween_property(_sprite, "rotation", rotation_amount, 0.5)
		. set_ease(Tween.EASE_OUT)
		. set_trans(Tween.TRANS_BOUNCE)
	)

	# Move slightly downward
	(
		tween
		. tween_property(_sprite, "position:y", _sprite.position.y + 20.0, 0.5)
		. set_ease(Tween.EASE_OUT)
		. set_trans(Tween.TRANS_BOUNCE)
	)

	# Fade out over 2 seconds (after rotation completes)
	tween.chain().tween_property(_sprite, "modulate:a", 0.0, 2.0)


func _finish_death() -> void:
	visible = false
	set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
	var wait := randf_range(MIN_RESPAWN_TIME, MAX_RESPAWN_TIME)
	_respawn_timer.wait_time = wait
	_respawn_timer.start()


func _respawn() -> void:
	var new_x := randf_range(ARENA_MARGIN, ARENA_WIDTH - ARENA_MARGIN)
	var new_y := randf_range(ARENA_MARGIN, ARENA_HEIGHT - ARENA_MARGIN)
	global_position = Vector2(new_x, new_y)
	_dead = false
	_damage_ready = true
	_hits_remaining = HITS_TO_KILL
	_update_health_bar()
	visible = true
	set_deferred("process_mode", Node.PROCESS_MODE_INHERIT)

	# Reset sprite properties modified by death tween
	_sprite.rotation = 0.0
	_sprite.position = Vector2.ZERO
	_sprite.modulate = Color.WHITE

	_sprite.play("idle")
	_facing_right = true
	_sprite.flip_h = false


func _update_health_bar() -> void:
	var ratio := float(_hits_remaining) / float(HITS_TO_KILL)
	_health_fill.size.x = HEALTH_BAR_WIDTH * ratio


func _on_animation_finished() -> void:
	if _dead or _player == null:
		return
	if _sprite.animation in ["defend", "attack"]:
		var distance := global_position.distance_to(_player.global_position)
		if distance > ATTACK_RANGE:
			_sprite.play("run")
		else:
			_sprite.play("idle")
