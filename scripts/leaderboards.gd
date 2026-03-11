extends CanvasLayer
## Leaderboards screen — displays leaderboard tables with tab navigation.

enum LeaderboardType { SCORE, ORE, XP, KILLS, TIME, AT_TIME, AT_XP, FASTEST_DEATH, DPS }

# Board IDs for each leaderboard type (replace placeholders with actual LEADR board IDs)
const BOARD_IDS: Dictionary = {
	LeaderboardType.SCORE: "brd_a313d59c-1fee-487a-98d8-e5f77b466f46",
	LeaderboardType.ORE: "brd_582a7a2f-0b5b-48ad-be71-f891b1d4ea3e",
	LeaderboardType.XP: "brd_8fd74728-46e4-4704-8a16-4ac046f48fe5",
	LeaderboardType.KILLS: "brd_26fd4784-72cc-42b1-bf7d-bbcbad390d27",
	LeaderboardType.TIME: "brd_c521d944-fd29-4cf9-b427-cc7a684bbaa3",
	LeaderboardType.AT_TIME: "brd_e4850af6-48da-45c4-9d89-926eb8f0c5d5",
	LeaderboardType.AT_XP: "brd_03e03437-8504-433f-8468-aac2da912b32",
	LeaderboardType.FASTEST_DEATH: "brd_ea7c8167-c1d6-442e-85db-376ec959bf5f",
	LeaderboardType.DPS: "brd_ba478d51-c618-4203-a9ce-42232cabe036",
}

var _cached_data: Dictionary = {}  # {LeaderboardType: Array of entries}
var _is_loading: bool = false
var _current_tab: LeaderboardType = LeaderboardType.SCORE
var _leaderboard_rows: Array[HBoxContainer] = []
var _tab_style_inactive: StyleBoxTexture
var _tab_style_active: StyleBoxTexture

@onready var _value_header: Label = %ValueHeader
@onready var _leaderboard_vbox: VBoxContainer = %LeaderboardVBox
@onready var _back_button: Button = %BackButton
@onready var _tab_buttons: Array[Button] = [%ScoreTab, %OreTab, %XPTab, %KillsTab, %TimeTab]
@onready var _button_sfx: AudioStreamPlayer = $ButtonSFX


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
	_button_sfx.play()
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
		LeaderboardType.AT_TIME:
			_value_header.text = "Play Time (All-Time)"
		LeaderboardType.AT_XP:
			_value_header.text = "XP (All-Time)"
		LeaderboardType.FASTEST_DEATH:
			_value_header.text = "Fastest Death"
		LeaderboardType.DPS:
			_value_header.text = "DPS"

	if _cached_data.has(_current_tab):
		_display_entries(_cached_data[_current_tab])
	else:
		_show_loading_state()
		_fetch_leaderboard_data(_current_tab)


func _show_loading_state() -> void:
	for row in _leaderboard_rows:
		var rank_label := row.get_node("Rank") as Label
		var name_label := row.get_node("Name") as Label
		var value_label := row.get_node("Value") as Label
		var date_label := row.get_node("Date") as Label
		rank_label.text = "-"
		name_label.text = "Loading..."
		name_label.remove_theme_color_override("font_color")
		value_label.text = "-"
		date_label.text = "-"


func _show_error_state(message: String) -> void:
	for i in range(_leaderboard_rows.size()):
		var row := _leaderboard_rows[i]
		var rank_label := row.get_node("Rank") as Label
		var name_label := row.get_node("Name") as Label
		var value_label := row.get_node("Value") as Label
		var date_label := row.get_node("Date") as Label
		rank_label.text = "-"
		name_label.text = message if i == 0 else ""
		name_label.remove_theme_color_override("font_color")
		value_label.text = ""
		date_label.text = ""


func _fetch_leaderboard_data(board_type: LeaderboardType) -> void:
	_is_loading = true
	var board_id: String = BOARD_IDS[board_type]
	var player_score_id: String = Stats.get_submitted_score_id(board_type)

	# Fetch top 3 scores
	var top_result: LeadrResult = await Leadr.get_scores(board_id, 3)
	var top_scores: Array = []
	if top_result.is_success:
		var page: LeadrPagedResult = top_result.data
		top_scores = page.items
	else:
		push_warning("Failed to fetch top scores: %s" % top_result.error.message)
		_show_error_state("Failed to load")
		_is_loading = false
		return

	# Fetch "around me" scores (5 scores centered on player)
	var around_scores: Array = []
	if not player_score_id.is_empty():
		var around_result: LeadrResult = await Leadr.get_scores(board_id, 5, "", player_score_id)
		if around_result.is_success:
			var page: LeadrPagedResult = around_result.data
			around_scores = page.items
		else:
			push_warning("Failed to fetch around scores: %s" % around_result.error.message)
	else:
		# No player score - fetch more top scores to fill around section
		var more_result: LeadrResult = await Leadr.get_scores(board_id, 8)
		if more_result.is_success:
			var all_scores: Array = more_result.data.items
			for i in range(3, mini(8, all_scores.size())):
				around_scores.append(all_scores[i])

	# Build combined entry list
	var entries: Array = _build_display_entries(top_scores, around_scores, player_score_id)

	# Cache and display
	_cached_data[board_type] = entries
	_is_loading = false

	# Only display if this tab is still selected
	if board_type == _current_tab:
		_display_entries(entries)


func _build_display_entries(
	top_scores: Array, around_scores: Array, player_score_id: String
) -> Array:
	var entries: Array = []
	var latest_rank := 0

	# Add top 3
	for i in range(3):
		if i < top_scores.size():
			var score: LeadrScore = top_scores[i]
			entries.append(_score_to_entry(score, score.id == player_score_id))
			latest_rank = score.rank
		else:
			entries.append(_empty_entry())

	# Add around me (5 entries)
	for i in range(5):
		if i < around_scores.size() and around_scores[i].rank > latest_rank:
			var score: LeadrScore = around_scores[i]
			entries.append(_score_to_entry(score, score.id == player_score_id))
		else:
			entries.append(_empty_entry())

	return entries


func _score_to_entry(score: LeadrScore, is_player: bool) -> Dictionary:
	return {
		"rank": score.rank,
		"name": score.player_name,
		"value": score.get_display_value(),
		"date": score.get_relative_time(),
		"is_player": is_player,
	}


func _empty_entry() -> Dictionary:
	return {
		"rank": 0,
		"name": "-",
		"value": "-",
		"date": "-",
		"is_player": false,
	}


func _display_entries(entries: Array) -> void:
	for i in range(_leaderboard_rows.size()):
		if i >= entries.size():
			break

		var row := _leaderboard_rows[i]
		var entry: Dictionary = entries[i]

		var rank_label := row.get_node("Rank") as Label
		var name_label := row.get_node("Name") as Label
		var value_label := row.get_node("Value") as Label
		var date_label := row.get_node("Date") as Label

		if entry["rank"] > 0:
			rank_label.text = str(entry["rank"])
		else:
			rank_label.text = "-"

		name_label.text = entry["name"]
		value_label.text = str(entry["value"])
		date_label.text = entry["date"]

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
	_button_sfx.play()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
