class_name Player
extends CharacterBody2D

@export_range(1, 2, 1) var player_id: int = 1

@export var character_name: String = "Fighter"
@export var speed: float = 61.0
@export var jump_velocity: float = -490.0
@export var gravity_scale: float = 1.0

@onready var state_machine: StateMachine = $StateMachine
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var opponent: Player = null

func _ready() -> void:
	for sibling in get_parent().get_children():
		if sibling is Player and sibling != self and sibling.player_id != player_id:
			opponent = sibling
			break

	if gravity == 0.0:
		gravity = 980.0
	gravity *= gravity_scale
	
	var initial_ball = get_node_or_null("HandMarker/Area2D")
	if initial_ball:
		initial_ball.visible = false
		initial_ball.process_mode = Node.PROCESS_MODE_DISABLED

	var hurtbox = get_node_or_null("HurtBox") as Area2D
	var hitbox = get_node_or_null("HitBox") as Area2D

	# Players use separate hitbox and hurtbox layers.
	if player_id == 2:
		if hurtbox:
			hurtbox.collision_layer = 16
			hurtbox.collision_mask = 2
		if hitbox:
			hitbox.collision_layer = 8
			hitbox.collision_mask = 4
	else:
		if hurtbox:
			hurtbox.collision_layer = 4
			hurtbox.collision_mask = 8
		if hitbox:
			hitbox.collision_layer = 2
			hitbox.collision_mask = 16

	state_machine.init(self)

func input_action(action: StringName) -> StringName:
	return StringName("%s_%d" % [action, player_id])

func _unhandled_input(event: InputEvent) -> void:
	state_machine.handle_input(event)

func take_hit(damage: float, attack_type: String) -> void:
	print("DEBUG: ", character_name, " was hit by a ", attack_type, " attack taking ", damage, " damage!")

	var current_state = state_machine.current_state
	if current_state is Block:
		var final_damage = current_state.evaluate_incoming_attack(attack_type, damage)
		print("DEBUG: Attack was blocked! Final chip damage: ", final_damage)
		return

	var hitstun_state = state_machine.states.get("hitstun") as HitStun
	if hitstun_state:
		hitstun_state.set_stun_duration(0.4)
		state_machine.change_state("hitstun")

func _process(delta: float) -> void:
	state_machine.update(delta)

func _physics_process(delta: float) -> void:
	state_machine.physics_update(delta)

	var facing_left := animated_sprite.flip_h
	if opponent:
		facing_left = opponent.global_position.x < global_position.x
	elif velocity.x != 0:
		facing_left = velocity.x < 0

	animated_sprite.flip_h = facing_left
	var hand_marker = get_node_or_null("HandMarker") as Node2D
	if hand_marker:
		hand_marker.position.x = -abs(hand_marker.position.x) if facing_left else abs(hand_marker.position.x)
