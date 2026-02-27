extends CharacterBody2D
## Player controller — click anywhere to move toward that point.

const MOVE_SPEED: float = 200.0
const ARRIVAL_THRESHOLD: float = 2.0
const PIXELS_PER_METER: float = 32.0

var _target_position: Vector2


func _ready() -> void:
	_target_position = position


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			_target_position = mb.position
			print("Click at ", mb.position, " → moving from ", position)


func stop() -> void:
	_target_position = position
	velocity = Vector2.ZERO


func _physics_process(_delta: float) -> void:
	var distance := position.distance_to(_target_position)
	if distance > ARRIVAL_THRESHOLD:
		var direction := position.direction_to(_target_position)
		velocity = direction * MOVE_SPEED
		var pos_before := position
		move_and_slide()
		var moved := position.distance_to(pos_before)
		if moved > 0.0:
			Stats.add_distance_traveled(moved / PIXELS_PER_METER)
	else:
		velocity = Vector2.ZERO
