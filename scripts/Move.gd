class_name Move
extends State

func enter() -> void:
	# Play movement/walk animation here
	player.animated_sprite.play("walk")
	pass

func physics_update(delta: float) -> void:
	# 1. Check if we fell off a ledge
	if not player.is_on_floor():
		player.velocity.y += player.gravity * delta
		player.move_and_slide()
		player.state_machine.change_state("jump")
		return

	# 2. Read directional input
	var input_dir := Input.get_axis("move_left", "move_right")
	# If the player stopped pressing direction keys, transition back to Idle
	if input_dir == 0:
		player.state_machine.change_state("idle")
		return

	# 3. Apply ground horizontal movement
	player.velocity.x = input_dir * player.speed
	player.move_and_slide()

	# 4. Check for state transitions
	# Jump check
	if Input.is_action_just_pressed("jump"):
		player.state_machine.change_state("jump")
		return

	# Attack check
	if Input.is_action_just_pressed("punch"):
		var attack_state = player.state_machine.states["attack"] as Attack
		attack_state.setup_attack("punch")
		player.state_machine.change_state("attack")
		return

	if Input.is_action_just_pressed("kick"):
		var attack_state = player.state_machine.states["attack"] as Attack
		attack_state.setup_attack("kick")
		player.state_machine.change_state("attack")
		return
