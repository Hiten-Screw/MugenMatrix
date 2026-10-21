class_name Attack
extends State

var current_attack: String = ""
var attack_duration: float = 0.0
var timer: float = 0.0

# Call this right before switching to the attack state
func setup_attack(attack_type: String) -> void:
	current_attack = attack_type
	if attack_type == "punch":
		attack_duration = 0.5 # How long the punch lasts (seconds)
		player.animated_sprite.play("punch")
	elif attack_type == "kick":
		attack_duration = 0.75 # Kicks usually take a bit longer than punches
		player.animated_sprite.play("kick")

func enter() -> void:
	timer = 0.0
	# Fighters usually plant their feet or slide slightly when attacking
	player.velocity.x = 0 

func physics_update(delta: float) -> void:
	timer += delta
	
	# Apply gravity if they jumped and attacked in mid-air
	if not player.is_on_floor():
		player.velocity.y += player.gravity * delta
	
	player.move_and_slide()

	# Future-proofing concept for cancels:
	if current_attack == "punch" and timer > 0.15: # if we are past the startup/active frames
		if Input.is_action_just_pressed("kick"):
			setup_attack("kick") # Instantly swap to kick data without leaving the state or resetting abruptly!
			timer = 0.0
			
	# When the attack duration ends, return to Idle or Move
	if timer >= attack_duration:
		if player.is_on_floor():
			var input_dir := Input.get_axis("move_left", "move_right")
			if input_dir != 0:
				player.state_machine.change_state("move")
			else:
				player.state_machine.change_state("idle")
		else:
			player.state_machine.change_state("jump")
