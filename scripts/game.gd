extends Node2D
## Game orchestrator — wires signals between child scenes and Stats.

@onready var _rock: StaticBody2D = $Rock


func _ready() -> void:
	_rock.ore_mined.connect(_on_ore_mined)


func _on_ore_mined() -> void:
	Stats.add_ore()
	Stats.add_xp(5)
