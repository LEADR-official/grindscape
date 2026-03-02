extends CanvasLayer
## Game over screen with leaderboards — displays final stats and handles restart.

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

# UI references
@onready var _score_label: RichTextLabel = %ScoreLabel
@onready var _ore_stat: Label = %OreStatLabel
@onready var _xp_stat: Label = %XPStatLabel
@onready var _kills_stat: Label = %KillsStatLabel
@onready var _time_stat: Label = %TimeStatLabel
@onready var _value_header: Label = %ValueHeader
@onready var _leaderboard_vbox: VBoxContainer = %LeaderboardVBox
@onready var _play_again_button: Button = %PlayAgainButton
@onready var _main_menu_button: Button = %MainMenuButton
@onready var _tab_buttons: Array[Button] = [%ScoreTab, %OreTab, %XPTab, %KillsTab, %TimeTab]


func _ready() -> void:
    hide()
    _setup_tab_styles()
    _cache_leaderboard_rows()
    _connect_tabs()
    _play_again_button.pressed.connect(_on_play_again)
    _main_menu_button.pressed.connect(_on_main_menu)


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

    # Remove focus highlight on tab buttons
    var empty_style := StyleBoxEmpty.new()
    for btn in _tab_buttons:
        btn.add_theme_stylebox_override("focus", empty_style)


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
        else:
            btn.add_theme_stylebox_override("normal", _tab_style_inactive)
            btn.add_theme_stylebox_override("hover", _tab_style_inactive)
            btn.add_theme_stylebox_override("pressed", _tab_style_inactive)


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

    _ore_stat.text = "Ore: %d" % Stats.ore_count
    _xp_stat.text = "XP: %.0f" % Stats.xp
    _kills_stat.text = "Kills: %d" % Stats.skeleton_kills
    _time_stat.text = "Time: %ds" % int(Stats.survival_time_seconds)

    _update_player_value(LeaderboardType.SCORE, score)
    _update_player_value(LeaderboardType.ORE, Stats.ore_count)
    _update_player_value(LeaderboardType.XP, Stats.xp)
    _update_player_value(LeaderboardType.KILLS, Stats.skeleton_kills)
    _update_player_value(LeaderboardType.TIME, Stats.survival_time_seconds)

    _current_tab = LeaderboardType.SCORE
    _update_tab_styles()
    _populate_leaderboard()

    show()


func _update_player_value(lb_type: LeaderboardType, value: float) -> void:
    var entries: Array = _leaderboard_data[lb_type]
    for entry in entries:
        if entry["is_player"]:
            entry["value"] = value
            break


func _on_play_again() -> void:
    Stats.reset()
    get_tree().paused = false
    get_tree().reload_current_scene()


func _on_main_menu() -> void:
    Stats.reset()
    get_tree().paused = false
    get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
