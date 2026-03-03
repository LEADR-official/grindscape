extends CanvasLayer
## Leaderboards screen — displays leaderboard tables with tab navigation.

enum LeaderboardType { SCORE, ORE, XP, KILLS, TIME }

const PLAYER_RANK := 7

# Hardcoded fake leaderboard data
var _leaderboard_data: Dictionary = {
	LeaderboardType.SCORE:
	[
		{"rank": 1, "name": "MiningKing", "value": 2847, "date": "Mar 1", "is_player": false},
		{"rank": 2, "name": "RockLover", "value": 2156, "date": "Feb 28", "is_player": false},
		{"rank": 3, "name": "OreHunter", "value": 1892, "date": "Feb 25", "is_player": false},
		{"rank": 5, "name": "CaveExplorer", "value": 1456, "date": "Feb 20", "is_player": false},
		{"rank": 6, "name": "PickaxePro", "value": 1298, "date": "Feb 15", "is_player": false},
		{"rank": 7, "name": "YOU", "value": 0, "date": "Today", "is_player": true},
		{"rank": 8, "name": "Digger42", "value": 1102, "date": "Feb 10", "is_player": false},
		{"rank": 9, "name": "StoneBreaker", "value": 987, "date": "Feb 5", "is_player": false},
	],
	LeaderboardType.ORE:
	[
		{"rank": 1, "name": "MiningKing", "value": 89, "date": "Mar 1", "is_player": false},
		{"rank": 2, "name": "RockLover", "value": 76, "date": "Feb 28", "is_player": false},
		{"rank": 3, "name": "OreHunter", "value": 64, "date": "Feb 25", "is_player": false},
		{"rank": 5, "name": "CaveExplorer", "value": 52, "date": "Feb 20", "is_player": false},
		{"rank": 6, "name": "PickaxePro", "value": 47, "date": "Feb 15", "is_player": false},
		{"rank": 7, "name": "YOU", "value": 0, "date": "Today", "is_player": true},
		{"rank": 8, "name": "Digger42", "value": 41, "date": "Feb 10", "is_player": false},
		{"rank": 9, "name": "StoneBreaker", "value": 38, "date": "Feb 5", "is_player": false},
	],
	LeaderboardType.XP:
	[
		{"rank": 1, "name": "MiningKing", "value": 312, "date": "Mar 1", "is_player": false},
		{"rank": 2, "name": "RockLover", "value": 287, "date": "Feb 28", "is_player": false},
		{"rank": 3, "name": "OreHunter", "value": 245, "date": "Feb 25", "is_player": false},
		{"rank": 5, "name": "CaveExplorer", "value": 196, "date": "Feb 20", "is_player": false},
		{"rank": 6, "name": "PickaxePro", "value": 172, "date": "Feb 15", "is_player": false},
		{"rank": 7, "name": "YOU", "value": 0, "date": "Today", "is_player": true},
		{"rank": 8, "name": "Digger42", "value": 158, "date": "Feb 10", "is_player": false},
		{"rank": 9, "name": "StoneBreaker", "value": 143, "date": "Feb 5", "is_player": false},
	],
	LeaderboardType.KILLS:
	[
		{"rank": 1, "name": "MiningKing", "value": 12, "date": "Mar 1", "is_player": false},
		{"rank": 2, "name": "RockLover", "value": 10, "date": "Feb 28", "is_player": false},
		{"rank": 3, "name": "OreHunter", "value": 9, "date": "Feb 25", "is_player": false},
		{"rank": 5, "name": "CaveExplorer", "value": 7, "date": "Feb 20", "is_player": false},
		{"rank": 6, "name": "PickaxePro", "value": 6, "date": "Feb 15", "is_player": false},
		{"rank": 7, "name": "YOU", "value": 0, "date": "Today", "is_player": true},
		{"rank": 8, "name": "Digger42", "value": 5, "date": "Feb 10", "is_player": false},
		{"rank": 9, "name": "StoneBreaker", "value": 4, "date": "Feb 5", "is_player": false},
	],
	LeaderboardType.TIME:
	[
		{"rank": 1, "name": "MiningKing", "value": 245, "date": "Mar 1", "is_player": false},
		{"rank": 2, "name": "RockLover", "value": 198, "date": "Feb 28", "is_player": false},
		{"rank": 3, "name": "OreHunter", "value": 176, "date": "Feb 25", "is_player": false},
		{"rank": 5, "name": "CaveExplorer", "value": 142, "date": "Feb 20", "is_player": false},
		{"rank": 6, "name": "PickaxePro", "value": 128, "date": "Feb 15", "is_player": false},
		{"rank": 7, "name": "YOU", "value": 0, "date": "Today", "is_player": true},
		{"rank": 8, "name": "Digger42", "value": 115, "date": "Feb 10", "is_player": false},
		{"rank": 9, "name": "StoneBreaker", "value": 102, "date": "Feb 5", "is_player": false},
	],
}

var _current_tab: LeaderboardType = LeaderboardType.SCORE
var _leaderboard_rows: Array[HBoxContainer] = []
var _tab_style_inactive: StyleBoxTexture
var _tab_style_active: StyleBoxTexture

@onready var _value_header: Label = %ValueHeader
@onready var _leaderboard_vbox: VBoxContainer = %LeaderboardVBox
@onready var _back_button: Button = %BackButton
@onready var _tab_buttons: Array[Button] = [%ScoreTab, %OreTab, %XPTab, %KillsTab, %TimeTab]


func _ready() -> void:
	_setup_tab_styles()
	_cache_leaderboard_rows()
	_connect_tabs()
	_back_button.pressed.connect(_on_back)
	_update_tab_styles()
	_populate_leaderboard()


func _setup_tab_styles() -> void:
	var tex_inactive := load("res://assets/frames/Border/panel-border-001.png") as Texture2D
	var tex_active := load("res://assets/frames/Border/panel-border-004.png") as Texture2D

	_tab_style_inactive = StyleBoxTexture.new()
	_tab_style_inactive.texture = tex_inactive
	_tab_style_inactive.texture_margin_left = 8
	_tab_style_inactive.texture_margin_top = 8
	_tab_style_inactive.texture_margin_right = 8
	_tab_style_inactive.texture_margin_bottom = 8
	_tab_style_inactive.modulate_color = Color(0.85, 0.78, 0.65, 1)

	_tab_style_active = StyleBoxTexture.new()
	_tab_style_active.texture = tex_active
	_tab_style_active.texture_margin_left = 8
	_tab_style_active.texture_margin_top = 8
	_tab_style_active.texture_margin_right = 8
	_tab_style_active.texture_margin_bottom = 8
	_tab_style_active.modulate_color = Color(0.7, 0.63, 0.5, 1)


func _cache_leaderboard_rows() -> void:
	for row_name in ["Row1", "Row2", "Row3", "Row5", "Row6", "Row7", "Row8", "Row9"]:
		var row := _leaderboard_vbox.get_node(row_name) as HBoxContainer
		_leaderboard_rows.append(row)


func _connect_tabs() -> void:
	for i in range(_tab_buttons.size()):
		_tab_buttons[i].pressed.connect(_on_tab_pressed.bind(i))


func _on_tab_pressed(tab_index: int) -> void:
	_current_tab = tab_index as LeaderboardType
	_update_tab_styles()
	_populate_leaderboard()


func _update_tab_styles() -> void:
	for i in range(_tab_buttons.size()):
		var btn := _tab_buttons[i]
		if i == _current_tab:
			btn.add_theme_stylebox_override("normal", _tab_style_active)
			btn.add_theme_stylebox_override("hover", _tab_style_active)
			btn.add_theme_stylebox_override("pressed", _tab_style_active)
			btn.add_theme_stylebox_override("focus", _tab_style_active)
			btn.add_theme_stylebox_override("hover_pressed", _tab_style_active)
			# Override font colors to match hover appearance (reddish brown)
			btn.add_theme_color_override("font_color", Color(0.4, 0.25, 0.1, 1))
			btn.add_theme_color_override("font_pressed_color", Color(0.4, 0.25, 0.1, 1))
			btn.add_theme_color_override("font_hover_color", Color(0.4, 0.25, 0.1, 1))
			btn.add_theme_color_override("font_focus_color", Color(0.4, 0.25, 0.1, 1))
		else:
			btn.add_theme_stylebox_override("normal", _tab_style_inactive)
			btn.add_theme_stylebox_override("hover", _tab_style_inactive)
			btn.add_theme_stylebox_override("pressed", _tab_style_inactive)
			btn.add_theme_stylebox_override("focus", _tab_style_inactive)
			btn.add_theme_stylebox_override("hover_pressed", _tab_style_inactive)
			# Remove color overrides for inactive tabs (use theme defaults)
			btn.remove_theme_color_override("font_color")
			btn.remove_theme_color_override("font_pressed_color")
			btn.remove_theme_color_override("font_hover_color")
			btn.remove_theme_color_override("font_focus_color")


func _populate_leaderboard() -> void:
	var entries: Array = _leaderboard_data[_current_tab]

	match _current_tab:
		LeaderboardType.SCORE:
			_value_header.text = "Score"
		LeaderboardType.ORE:
			_value_header.text = "Ore"
		LeaderboardType.XP:
			_value_header.text = "XP"
		LeaderboardType.KILLS:
			_value_header.text = "Kills"
		LeaderboardType.TIME:
			_value_header.text = "Time"

	for i in range(_leaderboard_rows.size()):
		var row := _leaderboard_rows[i]
		var entry: Dictionary = entries[i]

		var rank_label := row.get_node("Rank") as Label
		var name_label := row.get_node("Name") as Label
		var value_label := row.get_node("Value") as Label
		var date_label := row.get_node("Date") as Label

		rank_label.text = str(entry["rank"])
		name_label.text = entry["name"]
		date_label.text = entry["date"]

		var value: float = entry["value"]
		if _current_tab == LeaderboardType.TIME:
			value_label.text = "%ds" % int(value)
		elif _current_tab == LeaderboardType.SCORE:
			value_label.text = _format_number(int(value))
		else:
			value_label.text = str(int(value))

		if entry["is_player"]:
			name_label.add_theme_color_override("font_color", Color(0.6, 0.2, 0.1, 1))
		else:
			name_label.remove_theme_color_override("font_color")


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


func _on_back() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
