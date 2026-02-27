extends Node2D
## Game orchestrator — wires signals between child scenes and Stats.

const ORE_XP_VALUE: float = 3.25

@onready var _rock: StaticBody2D = $Rock
@onready var _player: CharacterBody2D = $Player


func _ready() -> void:
	_rock.ore_mined.connect(_on_ore_mined)


func _on_ore_mined() -> void:
	Stats.add_ore()
	Stats.add_xp(ORE_XP_VALUE)
	_player.stop()
