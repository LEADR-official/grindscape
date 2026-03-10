extends CanvasLayer
## Main menu — title screen with Play and Leaderboards buttons.

@onready var _play_button: Button = %PlayButton
@onready var _leaderboards_button: Button = %LeaderboardsButton
@onready var _button_sfx: AudioStreamPlayer = $ButtonSFX


func _ready() -> void:
	_play_button.pressed.connect(_on_play)
	_leaderboards_button.pressed.connect(_on_leaderboards)


func _on_play() -> void:
	_button_sfx.play()
	Stats.reset()
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_leaderboards() -> void:
	_button_sfx.play()
	get_tree().change_scene_to_file("res://scenes/leaderboards.tscn")
