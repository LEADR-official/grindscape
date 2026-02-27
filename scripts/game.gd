extends Node2D
## Game orchestrator — wires signals between child scenes and Stats.

const ORE_XP_VALUE: float = 3.25
const SKELETON_HIT_XP: float = 2.0
const SKELETON_KILL_XP: float = 7.0
const DAMAGE_PER_HIT: int = 1
const DAMAGE_TAKEN_XP: float = 1.0

@onready var _rock: StaticBody2D = $Rock
@onready var _player: CharacterBody2D = $Player
@onready var _skeleton: CharacterBody2D = $Skeleton


func _ready() -> void:
	_rock.ore_mined.connect(_on_ore_mined)
	_skeleton.skeleton_hit.connect(_on_skeleton_hit)
	_skeleton.skeleton_killed.connect(_on_skeleton_killed)
	_skeleton.skeleton_attacked_player.connect(_on_skeleton_attacked_player)
	_player.player_died.connect(_on_player_died)


func _on_ore_mined() -> void:
	Stats.add_ore()
	Stats.add_xp(ORE_XP_VALUE)
	_player.stop()


func _on_skeleton_hit() -> void:
	Stats.add_xp(SKELETON_HIT_XP)
	Stats.add_damage_dealt(1)
	_player.stop()


func _on_skeleton_killed() -> void:
	Stats.add_skeleton_kill()
	Stats.add_xp(SKELETON_KILL_XP)


func _on_skeleton_attacked_player() -> void:
	_player.take_damage(DAMAGE_PER_HIT)
	Stats.add_damage_taken(DAMAGE_PER_HIT)
	Stats.add_xp(DAMAGE_TAKEN_XP)


func _on_player_died() -> void:
	get_tree().paused = true
