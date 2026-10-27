class_name HitStun
extends State

var stun_duration: float = 0.0
var timer: float = 0.0

func set_stun_duration(duration: float) -> void:
	stun_duration = duration

func enter() -> void:
	timer = 0.0
	player.velocity.x = 0

func physics_update(delta: float) -> void:
	timer += delta
	
	if not player.is_on_floor():
		player.velocity.y += player.gravity * delta
	
	player.move_and_slide()

	if timer >= stun_duration:
		if player.is_on_floor():
			var input_dir := get_axis("move_left", "move_right")
			if input_dir != 0:
				player.state_machine.change_state("move")
			else:
				player.state_machine.change_state("idle")
		else:
			player.state_machine.change_state("jump")
