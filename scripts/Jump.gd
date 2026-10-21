class_name Jump
extends State

func enter() -> void:
	# 1. Play jumping animation (e.g., player.animated_sprite.play("jump"))
	
	# 2. Apply initial jump impulse if on the floor when entering
	if player.is_on_floor():
		player.velocity.y = player.jump_velocity
		
	player.animated_sprite.play("jump")

func physics_update(delta: float) -> void:
	# 1. Apply gravity while airborne
	player.velocity.y += player.gravity * delta

	# 2. Allow horizontal air drift
	var input_dir := Input.get_axis("move_left", "move_right")
	if input_dir != 0:
		player.velocity.x = input_dir * player.speed
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, player.speed)

	player.move_and_slide()

	# 3. Transitions
	# Air Attack check
	#if Input.is_action_just_pressed("attack"):
	#	player.state_machine.change_state("attack")
	#	return

	# Landing check
	if player.is_on_floor():
		# Transition to Move if holding a direction upon landing, otherwise Idle
		if input_dir != 0:
			player.state_machine.change_state("move")
		else:
			player.state_machine.change_state("idle")
		return
	
