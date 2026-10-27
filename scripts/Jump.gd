class_name Jump
extends State

func enter() -> void:
	if player.is_on_floor():
		player.velocity.y = player.jump_velocity
		
	player.animated_sprite.play("jump")

func physics_update(delta: float) -> void:
	player.velocity.y += player.gravity * delta

	var input_dir := get_axis("move_left", "move_right")
	if input_dir != 0:
		player.velocity.x = input_dir * player.speed
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, player.speed)

	player.move_and_slide()

	if player.is_on_floor():
		if input_dir != 0:
			player.state_machine.change_state("move")
		else:
			player.state_machine.change_state("idle")
		return
	
