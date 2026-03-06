extends CanvasLayer
## Name entry dialog — collects player display name before starting the game.

signal name_confirmed(player_name: String)
signal cancelled

var _default_name: String = ""

@onready var _name_input: LineEdit = %NameInput
@onready var _error_label: Label = %ErrorLabel
@onready var _confirm_button: Button = %ConfirmButton
@onready var _cancel_button: Button = %CancelButton


func _ready() -> void:
	hide()
	_confirm_button.pressed.connect(_on_confirm)
	_cancel_button.pressed.connect(_on_cancel)
	_name_input.text_submitted.connect(_on_text_submitted)
	_style_line_edit()


func _style_line_edit() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.78, 0.68, 0.52, 1)
	style.border_color = Color(0.4, 0.3, 0.2, 1)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	_name_input.add_theme_stylebox_override("normal", style)
	_name_input.add_theme_stylebox_override("focus", style)


func show_dialog() -> void:
	_error_label.text = ""
	_name_input.text = ""
	_default_name = "player_%d" % randi_range(1000, 9999)
	_name_input.placeholder_text = _default_name
	show()
	_name_input.grab_focus()


func _get_player_name() -> String:
	var entered := _name_input.text.strip_edges()
	if entered.is_empty():
		return _default_name
	return entered


func _on_confirm() -> void:
	var player_name := _get_player_name()
	if player_name.length() < 3:
		_error_label.text = "Name must be at least 3 characters"
		return
	_error_label.text = ""
	name_confirmed.emit(player_name)


func _on_text_submitted(_text: String) -> void:
	_on_confirm()


func _on_cancel() -> void:
	hide()
	cancelled.emit()
