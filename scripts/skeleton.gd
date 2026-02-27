extends CharacterBody2D
## Skeleton enemy — chases the player at a slow fixed speed, stops when in attack range.

const CHASE_SPEED: float = 80.0
const ATTACK_RANGE: float = 48.0

var _player: CharacterBody2D


func _ready() -> void:
	_player = get_tree().get_first_node_in_group("player") as CharacterBody2D


func _physics_process(_delta: float) -> void:
	if _player == null:
		return
	var distance := global_position.distance_to(_player.global_position)
	if distance > ATTACK_RANGE:
		velocity = global_position.direction_to(_player.global_position) * CHASE_SPEED
		move_and_slide()
	else:
		velocity = Vector2.ZERO
