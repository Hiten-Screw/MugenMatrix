class_name CharacterCombatStats
extends Resource

@export_range(1.0, 10000.0, 1.0) var max_hp: float = 100.0
@export_range(0.0, 10000.0, 1.0) var starting_hp: float = 100.0
@export_range(0.0, 10000.0, 1.0) var max_sp: float = 100.0
@export_range(0.0, 10000.0, 1.0) var starting_sp: float = 0.0
@export_range(0.0, 10000.0, 1.0) var max_mp: float = 100.0
@export_range(0.0, 10000.0, 1.0) var starting_mp: float = 100.0
@export_range(0.0, 1000.0, 0.1) var mp_regen_per_second: float = 5.0
@export_range(0.0, 10000.0, 0.1) var sp_on_hit_dealt: float = 10.0
@export_range(0.0, 10000.0, 0.1) var sp_on_hit_received: float = 5.0
