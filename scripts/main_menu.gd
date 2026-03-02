extends CanvasLayer
## Main menu — title screen with Play and Leaderboards buttons.

@onready var _play_button: Button = %PlayButton
@onready var _leaderboards_button: Button = %LeaderboardsButton


func _ready() -> void:
	_play_button.pressed.connect(_on_play)
	_leaderboards_button.disabled = true


func _on_play() -> void:
	Stats.reset()
	get_tree().change_scene_to_file("res://scenes/game.tscn")
