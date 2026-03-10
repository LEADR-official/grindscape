extends Node
## Background music manager — plays looping music throughout the game.

@onready var _player: AudioStreamPlayer = $AudioStreamPlayer


func _ready() -> void:
	_player.finished.connect(_on_music_finished)
	_player.play()


func _on_music_finished() -> void:
	_player.play()
