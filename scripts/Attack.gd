class_name Attack
extends State

var current_attack: String = ""
var attack_duration: float = 0.0
var timer: float = 0.0
var beam_spawned: bool = false # Tracks if the beam has appeared yet

# References for Special Attack
var beam_scene: PackedScene = preload("res://scenes/kame.tscn")

# Combo tracking
var combo_step: int = 1
var max_combo: int = 2 # e.g., Punch 1 -> Palm Strike
var buffered_next_attack: bool = false
var is_holding_attack: bool = false

# Call this right before switching to the attack state
func setup_attack(attack_type: String) -> void:
	current_attack = attack_type
	combo_step = 1
	buffered_next_attack = false
	beam_spawned = false
	_configure_attack_data()

func _configure_attack_data() -> void:
	if current_attack == "punch":
		if combo_step == 1:
			attack_duration = 0.625
			player.animated_sprite.play("punch_1")
		elif combo_step == 2:
			attack_duration = 0.4
			player.animated_sprite.play("punch_2")
	elif current_attack == "punch_heavy":
		attack_duration = 1.072
		player.animated_sprite.play("punch_heavy")
	elif current_attack == "kick":
		attack_duration = 0.6
		player.animated_sprite.play("kick")
	elif current_attack == "kick_heavy":
		attack_duration = 0.75
		player.animated_sprite.play("kick_heavy")
	elif current_attack == "special_1":
		attack_duration = 2.875
		beam_spawned = false
		var energy_ball = player.get_node_or_null("HandMarker/Area2D")
		if energy_ball:
			energy_ball.visible = true
			energy_ball.process_mode = Node.PROCESS_MODE_INHERIT
			var ball_sprite = energy_ball.get_node_or_null("AnimatedSprite2D")
			if ball_sprite:
				ball_sprite.play("ball")
		player.animated_sprite.play("special_1")	
		
		var anim_player = player.get_node_or_null("AnimationPlayer")
		if anim_player:
			if player.animated_sprite.flip_h and anim_player.has_animation("charge_l"):
				anim_player.play("charge_l")
			elif anim_player.has_animation("charge"):
				anim_player.play("charge")
		

func enter() -> void:
	timer = 0.0
	# Fighters usually plant their feet or slide slightly when attacking
	player.velocity.x = 0 
	buffered_next_attack = false

func physics_update(delta: float) -> void:
	timer += delta
	
	# Check if player is holding the attack button down
	is_holding_attack = Input.is_action_pressed("punch")
	
	# Buffer next attack if pressed during the cancel/combo window (e.g., after active frames)
	if current_attack == "punch" and timer > (attack_duration * 0.5):
		if Input.is_action_just_pressed("punch"):
			buffered_next_attack = true
	
	# Apply gravity if they jumped and attacked in mid-air
	if not player.is_on_floor():
		player.velocity.y += player.gravity * delta
	player.move_and_slide()

	# Future-proofing concept for cancels:
	if current_attack == "punch" and timer > 0.15: # if we are past the startup/active frames
		if Input.is_action_just_pressed("kick"):
			setup_attack("kick") # Instantly swap to kick data without leaving the state or resetting abruptly!
			timer = 0.0
			
	# Check for mid-charge beam spawn trigger at exactly 1.725 seconds
	if current_attack == "special_1" and not beam_spawned and timer >= 1.725:
		beam_spawned = true
		spawn_beam()
			
# When the current attack duration ends...
	if timer >= attack_duration:
		var should_continue = false
		
		if current_attack == "punch":
			# If the player pressed punch again during the attack OR is holding it down
			if buffered_next_attack or Input.is_action_pressed("punch"):
				combo_step += 1
				if combo_step > max_combo:
					combo_step = 1 # Loop back to punch 1 if held continuously
				should_continue = true
		
		if should_continue:
			# Reset timer and transition seamlessly to the next strike!
			timer = 0.0
			buffered_next_attack = false
			_configure_attack_data()
		else:
			# Combo ended, return to movement/idle
			if current_attack == "special_1":
				finish_special_attack() # Clean up ball, stop animation player, and exit state
			else:
				_exit_to_movement()

func spawn_beam() -> void:
	if not beam_scene:
		return
		
	var beam_instance = beam_scene.instantiate() as kame
	
	# Add beam to the world/scene root so it isn't tied to player movement
	player.get_parent().add_child(beam_instance)
	
	# Get HandMarker global position
	var marker = player.get_node_or_null("HandMarker")
	var spawn_pos = marker.global_position if marker else player.global_position
	
	# Determine facing direction
	var is_facing_left = player.animated_sprite.flip_h
	
	# Initialize beam position and facing direction
	beam_instance.setup(spawn_pos, is_facing_left)
			
func finish_special_attack() -> void:
	var energy_ball = player.get_node_or_null("HandMarker/Area2D")
	if energy_ball:
		energy_ball.visible = false
		energy_ball.process_mode = Node.PROCESS_MODE_DISABLED
		
	var anim_player = player.get_node_or_null("AnimationPlayer")
	if anim_player:
		anim_player.stop()

	_exit_to_movement()

func _exit_to_movement() -> void:
	if player.is_on_floor():
		var input_dir := Input.get_axis("move_left", "move_right")
		if input_dir != 0:
			player.state_machine.change_state("move")
		else:
			player.state_machine.change_state("idle")
	else:
			player.state_machine.change_state("jump")
