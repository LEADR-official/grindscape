extends CanvasLayer
## HUD — displays live ore, XP, and health counters.

const COLOR_HEALTHY := Color(0.459, 0.984, 0.298, 1)  # Neon green
const COLOR_LOW_HP := Color(0.984, 0.0, 0.035, 1)  # Bright red
const LOW_HP_THRESHOLD := 3

@onready var _ore_label: Label = $TopBar/OreLabel
@onready var _xp_label: Label = $TopBar/XPLabel
@onready var _health_label: Label = $TopBar/HealthLabel


func _ready() -> void:
	Stats.stats_updated.connect(_on_stats_updated)
	_on_stats_updated()
	var player := get_tree().get_first_node_in_group("player")
	if player:
		player.health_changed.connect(_on_health_changed)


func _on_stats_updated() -> void:
	_ore_label.text = str(Stats.ore_count)
	_xp_label.text = "XP: " + str(Stats.xp)


func _on_health_changed(current: int, maximum: int) -> void:
	_health_label.text = "HP: %d/%d" % [current, maximum]
	if current <= LOW_HP_THRESHOLD:
		_health_label.add_theme_color_override("font_color", COLOR_LOW_HP)
	else:
		_health_label.add_theme_color_override("font_color", COLOR_HEALTHY)
