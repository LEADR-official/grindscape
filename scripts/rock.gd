extends StaticBody2D
## Minable rock — click to mine when in range, 2s cooldown between mines.

signal ore_mined

const ROCK_COLOR := Color(0.55, 0.35, 0.17, 1)
const COOLDOWN_COLOR := Color(0.3, 0.3, 0.3, 1)

var _pending_mine: bool = false
var _on_cooldown: bool = false

@onready var _interaction_area: Area2D = $InteractionArea
@onready var _color_rect: ColorRect = $ColorRect
@onready var _cooldown_timer: Timer = $CooldownTimer


func _ready() -> void:
	_interaction_area.input_event.connect(_on_interaction_input_event)
	_interaction_area.body_entered.connect(_on_body_entered)
	_cooldown_timer.timeout.connect(_on_cooldown_finished)


func _on_interaction_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if _on_cooldown:
		return
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			_pending_mine = true
			print("Rock clicked, pending mine")
			for body in _interaction_area.get_overlapping_bodies():
				if body.is_in_group("player"):
					_mine()
					return


func _on_body_entered(body: Node2D) -> void:
	if _pending_mine and body.is_in_group("player"):
		_mine()


func _mine() -> void:
	_pending_mine = false
	_on_cooldown = true
	_color_rect.color = COOLDOWN_COLOR
	_cooldown_timer.start()
	ore_mined.emit()
	print("Ore mined! Stats.ore_count = ", Stats.ore_count)


func _on_cooldown_finished() -> void:
	_on_cooldown = false
	_color_rect.color = ROCK_COLOR
