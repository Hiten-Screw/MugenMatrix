class_name Attack
extends State

var current_slot: StringName
var current_definition: AttackDefinition
var combo_index: int = 0
var timer: float = 0.0
var projectile_spawned: bool = false
var buffered_combo: bool = false
var dash_active: bool = false
var dash_direction: float = 0.0

func setup_attack(slot: StringName) -> bool:
	if not player.attack_set:
		push_error("%s has no character attack set assigned." % player.character_name)
		return false

	var definition: AttackDefinition = player.attack_set.get_move(slot, 0)
	if not definition:
		push_error("%s has no move configured for attack slot '%s'." % [player.character_name, slot])
		return false
	if not player.try_pay_attack_cost(definition):
		return false

	if player.state_machine.current_state == self and current_definition:
		player.on_character_attack_finished(current_definition)

	current_slot = slot
	current_definition = definition
	combo_index = 0
	timer = 0.0
	projectile_spawned = false
	buffered_combo = false
	_configure_current_attack()
	return true

func _configure_current_attack() -> void:
	current_definition = player.attack_set.get_move(current_slot, combo_index)
	if not current_definition:
		push_error("%s has no move configured for attack slot '%s'." % [player.character_name, current_slot])
		return

	var hitbox := player.get_node_or_null("HitBox") as Hitbox
	if hitbox:
		hitbox.begin_attack()
		hitbox.damage = current_definition.damage * player.attack_set.damage_multiplier
		hitbox.attack_type = String(current_definition.attack_type)
		hitbox.attack_id = current_slot
	player.active_attack_id = current_slot

	var hitbox_node := player.get_node_or_null("HitBox") as Node2D
	if hitbox_node:
		hitbox_node.scale.x = -1.0 if current_definition.mirrors_hitbox_to_facing and player.animated_sprite.flip_h else 1.0
	var hitbox_shape := player.get_node_or_null("HitBox/CollisionShape2D") as CollisionShape2D
	if hitbox_shape and current_definition.enable_hitbox_on_start:
		hitbox_shape.set_deferred("disabled", false)

	if current_definition.animation_name != &"":
		if player.animated_sprite.sprite_frames.has_animation(current_definition.animation_name):
			player.animated_sprite.play(current_definition.animation_name)
		else:
			push_error("%s is missing sprite animation '%s'." % [player.character_name, current_definition.animation_name])

	var animation_player := player.get_node_or_null("AnimationPlayer") as AnimationPlayer
	if animation_player:
		var animation_name := current_definition.animation_player_name
		if player.animated_sprite.flip_h and current_definition.animation_player_left_name != &"":
			animation_name = current_definition.animation_player_left_name
		var explicitly_configured := animation_name != &""
		if not explicitly_configured:
			animation_name = current_definition.animation_name
		if animation_name != &"" and animation_player.has_animation(animation_name):
			animation_player.play(animation_name)
		elif explicitly_configured:
			push_error("%s is missing AnimationPlayer animation '%s'." % [player.character_name, animation_name])

	player.on_character_attack_started(current_definition)

func enter() -> void:
	timer = 0.0
	player.velocity.x = 0.0
	buffered_combo = false

func exit() -> void:
	if current_definition:
		player.on_character_attack_finished(current_definition)
	if dash_active:
		player.end_attack_dash()
		dash_active = false
		player.velocity.x = 0.0
	var hitbox := player.get_node_or_null("HitBox") as Hitbox
	if hitbox:
		hitbox.end_attack()
	var animation_player := player.get_node_or_null("AnimationPlayer") as AnimationPlayer
	if animation_player:
		animation_player.stop()
	var hitbox_shape := player.get_node_or_null("HitBox/CollisionShape2D") as CollisionShape2D
	if hitbox_shape:
		hitbox_shape.set_deferred("disabled", true)

func physics_update(delta: float) -> void:
	if not current_definition:
		_exit_to_movement()
		return

	var previous_timer := timer
	timer += delta

	if current_definition.combo_input != &"" and timer > current_definition.duration * 0.5:
		if is_action_just_pressed(current_definition.combo_input):
			buffered_combo = true

	if current_definition.cancel_input != &"" and timer > current_definition.cancel_after:
		if is_action_just_pressed(current_definition.cancel_input):
			if player.start_attack(current_definition.cancel_slot):
				return

	if not player.is_on_floor():
		player.velocity.y += player.gravity * delta
	_apply_attack_dash(previous_timer, delta)
	player.move_and_slide()

	if current_definition.projectile_spawn_time >= 0.0 \
	and not projectile_spawned \
	and timer >= current_definition.projectile_spawn_time:
		projectile_spawned = true
		player.spawn_character_projectile(current_definition)

	if timer < current_definition.duration:
		return

	var combo_size := player.attack_set.get_combo_size(current_slot)
	if combo_size > 1 and current_definition.combo_input != &"":
		if buffered_combo or is_action_pressed(current_definition.combo_input):
			var next_combo_index := (combo_index + 1) % combo_size
			var next_definition: AttackDefinition = player.attack_set.get_move(current_slot, next_combo_index)
			if next_definition and player.try_pay_attack_cost(next_definition):
				combo_index = next_combo_index
				timer = 0.0
				buffered_combo = false
				_configure_current_attack()
				return

	_exit_to_movement()

func _apply_attack_dash(previous_timer: float, delta: float) -> void:
	var dash_end_time := current_definition.dash_start_time + current_definition.dash_duration
	var dash_frame_start := maxf(previous_timer, current_definition.dash_start_time)
	var dash_frame_end := minf(timer, dash_end_time)
	var dash_time_this_frame := maxf(0.0, dash_frame_end - dash_frame_start)
	if dash_time_this_frame > 0.0 and delta > 0.0:
		if not dash_active:
			dash_direction = player.begin_attack_dash()
			dash_active = true
		player.velocity.x = dash_direction * current_definition.dash_speed * (dash_time_this_frame / delta)
	elif dash_active and previous_timer >= dash_end_time:
		player.end_attack_dash()
		dash_active = false
		player.velocity.x = 0.0

func _exit_to_movement() -> void:
	if player.is_on_floor():
		var input_dir := get_axis("move_left", "move_right")
		if input_dir != 0.0:
			player.state_machine.change_state("move")
		else:
			player.state_machine.change_state("idle")
	else:
		player.state_machine.change_state("jump")
