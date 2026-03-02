extends CanvasLayer
## Game over screen — displays final stats and handles restart.

@onready var _ore_label: Label = %OreLabel
@onready var _xp_label: Label = %XPLabel
@onready var _time_label: Label = %TimeLabel
@onready var _play_again_button: Button = %PlayAgainButton


func _ready() -> void:
	hide()
	_play_again_button.pressed.connect(_on_play_again)


func show_game_over() -> void:
	_ore_label.text = "Ore: %d" % Stats.ore_count
	_xp_label.text = "XP: %.0f" % Stats.xp
	_time_label.text = "Time: %ds" % int(Stats.survival_time_seconds)
	show()


func _on_play_again() -> void:
	Stats.reset()
	get_tree().paused = false
	get_tree().reload_current_scene()
