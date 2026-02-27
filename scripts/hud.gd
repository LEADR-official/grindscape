extends CanvasLayer
## HUD — displays live ore and XP counters, updated via Stats signal.

@onready var _ore_label: Label = $TopBar/OreLabel
@onready var _xp_label: Label = $TopBar/XPLabel


func _ready() -> void:
	Stats.stats_updated.connect(_on_stats_updated)
	_on_stats_updated()


func _on_stats_updated() -> void:
	_ore_label.text = str(Stats.ore_count)
	_xp_label.text = "XP: " + str(Stats.xp)
