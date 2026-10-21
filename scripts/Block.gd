class_name Block
extends State

var consecutive_blocks: int = 0

func enter() -> void:
	# Play your character's blocking stance animation
	player.animated_sprite.play("block")
	# Stop movement momentum when entering block
	player.velocity.x = 0

func physics_update(delta: float) -> void:
	# Apply gravity if the player is somehow blocking in the air (air block)
	if not player.is_on_floor():
		player.velocity.y += player.gravity * delta
		player.move_and_slide()
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, player.speed)
		player.move_and_slide()

	# Exit block state when the player lets go of the block button (or stops holding back)
	# Assuming you have an input action named "block" (or you check holding away from opponent)
	if not Input.is_action_pressed("block"):
		var input_dir := Input.get_axis("move_left", "move_right")
		if input_dir != 0:
			player.state_machine.change_state("move")
		else:
			player.state_machine.change_state("idle")
		return

# --- COMBAT LOGIC: Handling Incoming Attacks While Blocking ---
func evaluate_incoming_attack(attack_type: String, raw_damage: float) -> float:
	"""
	Called by the enemy's hitbox when it hits this player.
	Returns the final damage dealt (chip damage or full damage).
	"""
	
	# 1. Rule: Are Special attacks unblockable?
	if attack_type == "special":
		# Bypass block entirely! Force transition to HitStun and take full damage
		consecutive_blocks = 0
		player.state_machine.change_state("hitstun")
		return raw_damage

	# 2. Rule: Reduced damage based on Light vs. Heavy (Chip Damage)
	var chip_multiplier: float = 0.2 # Default: blocks negate 80% of damage
	if attack_type == "heavy":
		chip_multiplier = 0.4 # Heavy attacks deal more chip damage through blocks
	elif attack_type == "light":
		chip_multiplier = 0.1 # Light attacks deal very minor chip damage

	# 3. Rule: Guard Limit / Continuous Block Degradation
	# If you block too many attacks in a row without counterattacking, trigger a Guard Break!
	consecutive_blocks += 1
	if consecutive_blocks > 5:
		consecutive_blocks = 0
		player.state_machine.change_state("hitstun") # Guard broken!
		return raw_damage * 1.2 # Guard break bonus damage

	# Play a minor block-impact animation or recoil
	player.animated_sprite.play("block_impact")
	
	# Return reduced chip damage
	return raw_damage * chip_multiplier

func exit() -> void:
	# Reset consecutive block count if the player drops their guard
	consecutive_blocks = 0
