class_name HitStun
extends State

var stun_duration: float = 0.0
var timer: float = 0.0

# Call this right before transitioning into HitStun to set how long they stay stunned
func set_stun_duration(duration: float) -> void:
	stun_duration = duration

func enter() -> void:
	timer = 0.0
	# 1. Clear velocity or apply a small knockback pushback
	player.velocity.x = 0
	# e.g., player.animated_sprite.play("hurt")

func physics_update(delta: float) -> void:
	timer += delta
	
	# Apply gravity if they got hit in the air (juggle state)
	if not player.is_on_floor():
		player.velocity.y += player.gravity * delta
	
	player.move_and_slide()

	# Once the hitstun duration finishes, recover back to Idle, Move, or Jump
	if timer >= stun_duration:
		if player.is_on_floor():
			var input_dir := Input.get_axis("move_left", "move_right")
			if input_dir != 0:
				player.state_machine.change_state("move")
			else:
				player.state_machine.change_state("idle")
		else:
			player.state_machine.change_state("jump")
