extends Node
## Stats autoload — single source of truth for all game metrics.
## Registered as an autoload in Project Settings.
## Emits `stats_updated` after every mutation so the HUD can react.

signal stats_updated

# --- Raw metrics ---
var ore_count: int = 0
var xp: int = 0
var skeleton_kills: int = 0
var damage_taken: int = 0
var damage_dealt: int = 0
var survival_time_seconds: float = 0.0

# --- Derived stats ---


func get_kill_death_ratio() -> float:
	if damage_taken == 0:
		return 0.0
	return float(skeleton_kills) / float(damage_taken)


func get_dps() -> float:
	if survival_time_seconds <= 0.0:
		return 0.0
	return float(damage_dealt) / survival_time_seconds


# --- Mutation methods ---


func add_ore(amount: int = 1) -> void:
	ore_count += amount
	stats_updated.emit()


func add_xp(amount: int) -> void:
	xp += amount
	stats_updated.emit()


func add_skeleton_kill() -> void:
	skeleton_kills += 1
	stats_updated.emit()


func add_damage_taken(amount: int) -> void:
	damage_taken += amount
	stats_updated.emit()


func add_damage_dealt(amount: int) -> void:
	damage_dealt += amount
	stats_updated.emit()


func add_survival_time(delta: float) -> void:
	survival_time_seconds += delta
	stats_updated.emit()


# --- Reset for Play Again flow ---


func reset() -> void:
	ore_count = 0
	xp = 0
	skeleton_kills = 0
	damage_taken = 0
	damage_dealt = 0
	survival_time_seconds = 0.0
	stats_updated.emit()
