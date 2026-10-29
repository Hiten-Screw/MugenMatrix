class_name HitStun
extends State

const STUN_DURATION: float = 1.0

var timer: float = 0.0

func enter() -> void:
	timer = 0.0
	player.velocity.x = 0
	if player.animated_sprite.sprite_frames.has_animation(&"hurt"):
		player.animated_sprite.sprite_frames.set_animation_loop(&"hurt", false)
		player.animated_sprite.play(&"hurt")

func physics_update(delta: float) -> void:
	timer += delta
	
	if not player.is_on_floor():
		player.velocity.y += player.gravity * delta
	
	player.move_and_slide()

	if timer >= STUN_DURATION:
		if player.is_on_floor():
			var input_dir := get_axis("move_left", "move_right")
			if input_dir != 0:
				player.state_machine.change_state("move")
			else:
				player.state_machine.change_state("idle")
		else:
			player.state_machine.change_state("jump")
