class_name CharacterAttackSet
extends Resource

@export_range(0.0, 10.0, 0.05) var damage_multiplier: float = 1.0
@export var light_punch_combo: Array[AttackDefinition] = []
@export var light_kick: AttackDefinition
@export var heavy_punch: AttackDefinition
@export var heavy_kick: AttackDefinition
@export var projectile: AttackDefinition

func get_move(slot: StringName, combo_index: int = 0) -> AttackDefinition:
	match slot:
		&"light_punch":
			if light_punch_combo.is_empty():
				return null
			return light_punch_combo[posmod(combo_index, light_punch_combo.size())]
		&"light_kick":
			return light_kick
		&"heavy_punch":
			return heavy_punch
		&"heavy_kick":
			return heavy_kick
		&"projectile":
			return projectile
		_:
			return null

func get_combo_size(slot: StringName) -> int:
	if slot == &"light_punch":
		return light_punch_combo.size()
	return 0
