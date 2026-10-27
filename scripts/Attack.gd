class_name Attack
extends State

var current_attack: String = ""
var attack_duration: float = 0.0
var timer: float = 0.0
var beam_spawned: bool = false

var beam_scene_right: PackedScene = preload("res://scenes/kame.tscn")
var beam_scene_left: PackedScene = preload("res://scenes/kame_l.tscn")

var combo_step: int = 1
var max_combo: int = 2
var buffered_next_attack: bool = false
var is_holding_attack: bool = false

func setup_attack(attack_type: String) -> void:
	current_attack = attack_type
	combo_step = 1
	buffered_next_attack = false
	beam_spawned = false
	_configure_attack_data()

func _configure_attack_data() -> void:
	var hitbox = player.get_node_or_null("HitBox") as Hitbox
	var anim_player = player.get_node_or_null("AnimationPlayer")
	if hitbox:
		hitbox.begin_attack()

	if current_attack == "punch":
		if combo_step == 1:
			attack_duration = 0.625
			_play_facing_attack_animation("punch_1")
			if hitbox:
				hitbox.damage = 7.0
				hitbox.attack_type = "punch_1"
		elif combo_step == 2:
			attack_duration = 0.4
			_play_facing_attack_animation("punch_2")
			if hitbox:
				hitbox.damage = 7.0
				hitbox.attack_type = "punch_2"

	elif current_attack == "punch_heavy":
		attack_duration = 1.072
		_play_facing_attack_animation("punch_heavy")
		if hitbox:
			hitbox.damage = 7.0
			hitbox.attack_type = "punch_heavy"

	elif current_attack == "kick":
		attack_duration = 0.6
		_play_facing_attack_animation("kick")
		if hitbox:
			hitbox.damage = 7.0
			hitbox.attack_type = "kick"

	elif current_attack == "kick_heavy":
		attack_duration = 0.75
		_play_facing_attack_animation("kick_heavy")
		if hitbox:
			hitbox.damage = 7.0
			hitbox.attack_type = "kick_heavy"

	elif current_attack == "special_1":
		attack_duration = 2.875
		beam_spawned = false
		if hitbox:
			hitbox.damage = 50.0
			hitbox.attack_type = "special_1"

		var energy_ball = player.get_node_or_null("HandMarker/Area2D")
		if energy_ball:
			energy_ball.visible = true
			energy_ball.process_mode = Node.PROCESS_MODE_INHERIT
			var ball_sprite = energy_ball.get_node_or_null("AnimatedSprite2D")
			if ball_sprite:
				ball_sprite.play("ball")

		player.animated_sprite.play("special_1")
		_set_hitbox_mirrored(false)
		if anim_player:
			if player.animated_sprite.flip_h and anim_player.has_animation("charge_l"):
				anim_player.play("charge_l")
			elif anim_player.has_animation("charge"):
				anim_player.play("charge")

func _play_facing_attack_animation(animation_name: String) -> void:
	_set_hitbox_mirrored(true)
	player.animated_sprite.play(animation_name)
	var anim_player = player.get_node_or_null("AnimationPlayer")
	if anim_player and anim_player.has_animation(animation_name):
		anim_player.play(animation_name)

func _set_hitbox_mirrored(mirror_to_facing: bool) -> void:
	var hitbox = player.get_node_or_null("HitBox") as Node2D
	if hitbox:
		hitbox.scale.x = -1.0 if mirror_to_facing and player.animated_sprite.flip_h else 1.0

func enter() -> void:
	timer = 0.0
	player.velocity.x = 0 
	buffered_next_attack = false

func physics_update(delta: float) -> void:
	timer += delta
	
	is_holding_attack = is_action_pressed("punch_1")
	
	if current_attack == "punch" and timer > (attack_duration * 0.5):
		if is_action_just_pressed("punch_1"):
			buffered_next_attack = true
	
	if not player.is_on_floor():
		player.velocity.y += player.gravity * delta
	player.move_and_slide()

	if current_attack == "punch" and timer > 0.15:
		if is_action_just_pressed("kick_1"):
			setup_attack("kick")
			timer = 0.0
			
	# Spawn the beam during the special attack's charge.
	if current_attack == "special_1" and not beam_spawned and timer >= 1.725:
		beam_spawned = true
		spawn_beam()
			
	if timer >= attack_duration:
		var should_continue = false
		
		if current_attack == "punch":
			if buffered_next_attack or is_action_pressed("punch_1"):
				combo_step += 1
				if combo_step > max_combo:
					combo_step = 1
				should_continue = true
		
		if should_continue:
			timer = 0.0
			buffered_next_attack = false
			_configure_attack_data()
		else:
			if current_attack == "special_1":
				finish_special_attack()
			else:
				_exit_to_movement()

func spawn_beam() -> void:
	var is_facing_left = player.animated_sprite.flip_h
	
	var selected_scene = beam_scene_left if is_facing_left else beam_scene_right
	if not selected_scene:
		return
		
	var beam_instance = selected_scene.instantiate()
	if not beam_instance:
		return
		
	
	player.get_parent().add_child(beam_instance)
	
	var marker = player.get_node_or_null("HandMarker")
	var spawn_pos = marker.global_position if marker else player.global_position
			
	beam_instance.setup(spawn_pos, is_facing_left)
			
func finish_special_attack() -> void:
	var anim_player = player.get_node_or_null("AnimationPlayer")
	var energy_ball = player.get_node_or_null("HandMarker/Area2D")
	if energy_ball:
		energy_ball.visible = false
		energy_ball.process_mode = Node.PROCESS_MODE_DISABLED
	if anim_player:
		anim_player.stop()
		var hitbox_shape = player.get_node_or_null("HitBox/CollisionShape2D")
		if hitbox_shape:
			hitbox_shape.disabled = true

	_exit_to_movement()

func _exit_to_movement() -> void:
	var anim_player = player.get_node_or_null("AnimationPlayer")
	if anim_player:
		anim_player.stop()
	var hitbox_shape = player.get_node_or_null("HitBox/CollisionShape2D")
	if hitbox_shape:
		hitbox_shape.disabled = true
	if player.is_on_floor():
		var input_dir := get_axis("move_left", "move_right")
		if input_dir != 0:
			player.state_machine.change_state("move")
		else:
			player.state_machine.change_state("idle")
	else:
			player.state_machine.change_state("jump")
