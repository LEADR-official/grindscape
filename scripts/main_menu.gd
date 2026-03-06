extends CanvasLayer
## Main menu — title screen with Play and Leaderboards buttons.

@onready var _play_button: Button = %PlayButton
@onready var _leaderboards_button: Button = %LeaderboardsButton
@onready var _button_sfx: AudioStreamPlayer = $ButtonSFX
@onready var _name_entry_dialog: CanvasLayer = $NameEntryDialog


func _ready() -> void:
	_play_button.pressed.connect(_on_play)
	_leaderboards_button.pressed.connect(_on_leaderboards)
	_name_entry_dialog.name_confirmed.connect(_on_name_confirmed)
	_name_entry_dialog.cancelled.connect(_on_name_cancelled)


func _on_play() -> void:
	_button_sfx.play()
	_name_entry_dialog.show_dialog()


func _on_name_confirmed(player_name: String) -> void:
	Stats.set_player_name(player_name)
	Stats.reset()
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_name_cancelled() -> void:
	pass


func _on_leaderboards() -> void:
	_button_sfx.play()
	get_tree().change_scene_to_file("res://scenes/leaderboards.tscn")
