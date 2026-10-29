class_name Saber
extends Player

const EXCAL_SCENE_RIGHT: PackedScene = preload("res://scenes/excal.tscn")
const EXCAL_SCENE_LEFT: PackedScene = preload("res://scenes/excal_l.tscn")

func spawn_character_projectile(definition: AttackDefinition) -> void:
	if definition.projectile_spawn_time < 0.0:
		return

	var facing_left := animated_sprite.flip_h
	var projectile_scene := EXCAL_SCENE_LEFT if facing_left else EXCAL_SCENE_RIGHT
	var projectile := projectile_scene.instantiate() as Excal
	if not projectile:
		push_error("Saber's Excal scene must have the Excal script attached.")
		return

	var spawn_position := global_position
	projectile.setup(
		spawn_position,
		facing_left,
		definition.projectile_damage * attack_set.damage_multiplier,
		self,
		active_attack_id
	)
	get_parent().add_child(projectile)
