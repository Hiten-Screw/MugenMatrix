class_name Block
extends State

var consecutive_blocks: int = 0

func enter() -> void:
	player.animated_sprite.play("block")
	player.animated_sprite.frame = 1
	player.animated_sprite.pause()
	player.velocity.x = 0

func physics_update(delta: float) -> void:
	if not player.is_on_floor():
		player.velocity.y += player.gravity * delta
		player.move_and_slide()
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, player.speed)
		player.move_and_slide()

	if not is_action_pressed("block"):
		var input_dir := get_axis("move_left", "move_right")
		if input_dir != 0:
			player.state_machine.change_state("move")
		else:
			player.state_machine.change_state("idle")
		return

func evaluate_incoming_attack(attack_type: String, raw_damage: float) -> float:
	if attack_type == "special":
		# Special attacks bypass blocking.
		consecutive_blocks = 0
		player.state_machine.change_state("hitstun")
		return raw_damage

	var chip_multiplier: float = 0.2
	if attack_type == "heavy":
		chip_multiplier = 0.4
	elif attack_type == "light":
		chip_multiplier = 0.1

	consecutive_blocks += 1
	if consecutive_blocks > 5:
		consecutive_blocks = 0
		player.state_machine.change_state("hitstun")
		return raw_damage * 1.2

	return raw_damage * chip_multiplier

func exit() -> void:
	consecutive_blocks = 0
