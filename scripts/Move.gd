class_name Move
extends State

func enter() -> void:
	player.animated_sprite.play("walk")
	pass

func physics_update(delta: float) -> void:

	if not player.is_on_floor():
		player.velocity.y += player.gravity * delta
		player.move_and_slide()
		player.state_machine.change_state("jump")
		return
	var input_dir := get_axis("move_left", "move_right")
	if input_dir == 0:
		player.state_machine.change_state("idle")
		return

	player.velocity.x = input_dir * player.speed
	player.move_and_slide()

	if is_action_just_pressed("jump"):
		player.state_machine.change_state("jump")
		return

	if player.try_start_attack():
		return
		
	if is_action_pressed("block"):
		player.state_machine.change_state("block")
		return
