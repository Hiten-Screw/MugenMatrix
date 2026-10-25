class_name Idle
extends State

func enter() -> void:
	# Trigger your idle animation here
	player.animated_sprite.play("idle")
	pass

func physics_update(delta: float) -> void:
	# 1. Apply gravity if airborne
	if not player.is_on_floor():
		player.velocity.y += player.gravity * delta
		player.move_and_slide()
		# If we fell off a ledge, immediately switch to Jump/Fall state
		player.state_machine.change_state("jump")
		return

	# 2. Decelerate ground velocity to zero
	player.velocity.x = move_toward(player.velocity.x, 0, player.speed)
	player.move_and_slide()

	# 3. Transitions
	# Jump check
	if Input.is_action_just_pressed("jump"):
		player.state_machine.change_state("jump")
		return

	# Movement check
	var input_dir := Input.get_axis("move_left", "move_right")
	if input_dir != 0:
		player.state_machine.change_state("move")
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
		
	# Light Punch (U key)
	if Input.is_action_just_pressed("punch"):
		var attack_state = player.state_machine.states["attack"] as Attack
		attack_state.setup_attack("punch")
		player.state_machine.change_state("attack")
		return

	# Heavy Punch (I key)
	if Input.is_action_just_pressed("punch_heavy"):
		var attack_state = player.state_machine.states["attack"] as Attack
		attack_state.setup_attack("punch_heavy")
		player.state_machine.change_state("attack")
		return

	# Light Kick (J key)
	if Input.is_action_just_pressed("kick"):
		var attack_state = player.state_machine.states["attack"] as Attack
		attack_state.setup_attack("kick")
		player.state_machine.change_state("attack")
		return

	# Heavy Kick (K key)
	if Input.is_action_just_pressed("kick_heavy"):
		var attack_state = player.state_machine.states["attack"] as Attack
		attack_state.setup_attack("kick_heavy")
		player.state_machine.change_state("attack")
		return
		
	# Special_1 (O key)
	if Input.is_action_just_pressed("special_1"):
		var attack_state = player.state_machine.states["attack"] as Attack
		attack_state.setup_attack("special_1")
		player.state_machine.change_state("attack")
		return
		
	if Input.is_action_pressed("block"):
		player.state_machine.change_state("block")
		return
