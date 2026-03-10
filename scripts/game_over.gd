extends CanvasLayer
## Game over screen — displays final stats and handles restart.

const PLAYER_RANK := 7

@onready var _score_label: RichTextLabel = %ScoreLabel
@onready var _ore_label: Label = %OreLabel
@onready var _xp_label: Label = %XPLabel
@onready var _kills_label: Label = %KillsLabel
@onready var _time_label: Label = %TimeLabel
@onready var _leaderboards_button: Button = %LeaderboardsButton
@onready var _play_again_button: Button = %PlayAgainButton
@onready var _main_menu_button: Button = %MainMenuButton
@onready var _button_sfx: AudioStreamPlayer = $ButtonSFX


func _ready() -> void:
	hide()
	_leaderboards_button.pressed.connect(_on_leaderboards)
	_play_again_button.pressed.connect(_on_play_again)
	_main_menu_button.pressed.connect(_on_main_menu)


func _format_number(n: int) -> String:
	var s := str(n)
	var result := ""
	var count := 0
	for i in range(s.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			result = "," + result
		result = s[i] + result
		count += 1
	return result


func _ordinal(n: int) -> String:
	if n % 100 >= 11 and n % 100 <= 13:
		return "%dth" % n
	match n % 10:
		1:
			return "%dst" % n
		2:
			return "%dnd" % n
		3:
			return "%drd" % n
		_:
			return "%dth" % n


func show_game_over() -> void:
	var score := Stats.get_score()
	var score_str := _format_number(int(score))
	var rank_str := _ordinal(PLAYER_RANK)

	_score_label.text = (
		"[center]You scored [color=#1020FE]%s[/color] and ranked [color=#1020FE]%s[/color]![/center]"
		% [score_str, rank_str]
	)

	_ore_label.text = "Ore: %d" % Stats.ore_count
	_xp_label.text = "XP: %.0f" % Stats.xp
	_kills_label.text = "Kills: %d" % Stats.skeleton_kills
	_time_label.text = "Time: %ds" % int(Stats.survival_time_seconds)

	show()


func _on_leaderboards() -> void:
	_button_sfx.play()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/leaderboards.tscn")


func _on_play_again() -> void:
	_button_sfx.play()
	Stats.reset()
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_main_menu() -> void:
	_button_sfx.play()
	Stats.reset()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
