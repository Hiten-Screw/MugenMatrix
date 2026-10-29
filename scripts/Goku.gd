class_name Goku
extends Player

const KAME_SCENE_RIGHT: PackedScene = preload("res://scenes/kame.tscn")
const KAME_SCENE_LEFT: PackedScene = preload("res://scenes/kame_l.tscn")

func on_character_attack_started(definition: AttackDefinition) -> void:
	if definition.move_id != &"special_1":
		return

	var energy_ball := get_node_or_null("HandMarker/Area2D")
	if not energy_ball:
		push_error("Goku's special attack requires HandMarker/Area2D.")
		return

	energy_ball.visible = true
	energy_ball.process_mode = Node.PROCESS_MODE_INHERIT
	var ball_sprite := energy_ball.get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
	if ball_sprite:
		ball_sprite.play("ball")

func spawn_character_projectile(definition: AttackDefinition) -> void:
	if definition.move_id != &"special_1":
		return

	var facing_left := animated_sprite.flip_h
	var projectile_scene := KAME_SCENE_LEFT if facing_left else KAME_SCENE_RIGHT
	var projectile := projectile_scene.instantiate()
	if not projectile.has_method("setup"):
		push_error("Goku's projectile scene must implement setup(position, facing_left).")
		projectile.free()
		return

	var marker := get_node_or_null("HandMarker") as Node2D
	var spawn_position := marker.global_position if marker else global_position
	get_parent().add_child(projectile)
	projectile.set("damage_per_tick", definition.projectile_damage * attack_set.damage_multiplier)
	projectile.call("setup", spawn_position, facing_left)

func on_character_attack_finished(definition: AttackDefinition) -> void:
	if definition.move_id != &"special_1":
		return

	var energy_ball := get_node_or_null("HandMarker/Area2D")
	if energy_ball:
		energy_ball.visible = false
		energy_ball.process_mode = Node.PROCESS_MODE_DISABLED
