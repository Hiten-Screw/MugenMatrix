class_name Idle
extends State

func enter() -> void:
	player.animated_sprite.play("idle")
	pass

func physics_update(delta: float) -> void:

	if not player.is_on_floor():
		player.velocity.y += player.gravity * delta
		player.move_and_slide()
		player.state_machine.change_state("jump")
		return
	player.velocity.x = move_toward(player.velocity.x, 0, player.speed)
	player.move_and_slide()

	if is_action_just_pressed("jump"):
		player.state_machine.change_state("jump")
		return

	var input_dir := get_axis("move_left", "move_right")
	if input_dir != 0:
		player.state_machine.change_state("move")
		return

	if is_action_just_pressed("punch_1"):
		var attack_state = player.state_machine.states["attack"] as Attack
		attack_state.setup_attack("punch")
		player.state_machine.change_state("attack")
		return

	if is_action_just_pressed("kick_1"):
		var attack_state = player.state_machine.states["attack"] as Attack
		attack_state.setup_attack("kick")
		player.state_machine.change_state("attack")
		return
		
	if is_action_just_pressed("punch_1"):
		var attack_state = player.state_machine.states["attack"] as Attack
		attack_state.setup_attack("punch")
		player.state_machine.change_state("attack")
		return

	if is_action_just_pressed("punch_2"):
		var attack_state = player.state_machine.states["attack"] as Attack
		attack_state.setup_attack("punch_heavy")
		player.state_machine.change_state("attack")
		return

	if is_action_just_pressed("kick_1"):
		var attack_state = player.state_machine.states["attack"] as Attack
		attack_state.setup_attack("kick")
		player.state_machine.change_state("attack")
		return

	if is_action_just_pressed("kick_2"):
		var attack_state = player.state_machine.states["attack"] as Attack
		attack_state.setup_attack("kick_heavy")
		player.state_machine.change_state("attack")
		return
		
	if is_action_just_pressed("special_1"):
		var attack_state = player.state_machine.states["attack"] as Attack
		attack_state.setup_attack("special_1")
		player.state_machine.change_state("attack")
		return
		
	if is_action_pressed("block"):
		player.state_machine.change_state("block")
		return
