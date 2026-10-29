class_name Block
extends State

const HITSTUN_BLOCK_COUNT: int = 8
const MITIGATION_LOSS_PER_BLOCK: float = 0.1

var consecutive_blocks: int = 0
var blocked_attack_count: int = 0
var last_blocked_attack_id: StringName

func reset_block_sequence() -> void:
	consecutive_blocks = 0
	blocked_attack_count = 0
	last_blocked_attack_id = &""

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

func evaluate_incoming_attack(attack_type: String, raw_damage: float, attack_id: StringName) -> float:
	if attack_type == "special":
		reset_block_sequence()
		return raw_damage

	var base_mitigation: float = 0.8
	if attack_type == "heavy":
		base_mitigation = 0.6
	elif attack_type == "light":
		base_mitigation = 0.9

	if attack_id == last_blocked_attack_id:
		consecutive_blocks = 1
	else:
		consecutive_blocks += 1
	last_blocked_attack_id = attack_id

	var mitigation := maxf(0.0, base_mitigation - blocked_attack_count * MITIGATION_LOSS_PER_BLOCK)
	blocked_attack_count += 1
	var damage_after_block := raw_damage * (1.0 - mitigation)
	if consecutive_blocks >= HITSTUN_BLOCK_COUNT:
		reset_block_sequence()
		player.apply_hitstun()

	return damage_after_block
