class_name Player
extends CharacterBody2D

# --- CHARACTER CONFIGURATION (Customizable per fighter in the Inspector) ---
@export var character_name: String = "Fighter"
@export var speed: float = 61.0
@export var jump_velocity: float = -490.0
@export var gravity_scale: float = 1.0

# References to nodes inside this specific character scene
@onready var state_machine: StateMachine = $StateMachine
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D # Or Sprite2D / AnimationPlayer

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	# Apply gravity multiplier if characters have different weight classes
	if gravity == 0.0:
		gravity = 980.0
	gravity *= gravity_scale
	
	# Hide energy ball on startup
	var initial_ball = get_node_or_null("HandMarker/Area2D")
	if initial_ball:
		initial_ball.visible = false
		initial_ball.process_mode = Node.PROCESS_MODE_DISABLED
	
	# Initialize the FSM and pass a reference of this player to all states
	state_machine.init(self)

func _unhandled_input(event: InputEvent) -> void:
	state_machine.handle_input(event)

func _process(delta: float) -> void:
	state_machine.update(delta)

func _physics_process(delta: float) -> void:
	state_machine.physics_update(delta)
	
	#FLIP
	if velocity.x > 0:
		animated_sprite.flip_h = false
		var hand_marker = get_node_or_null("HandMarker")
		if hand_marker and hand_marker.position.x < 0:
			hand_marker.position.x = abs(hand_marker.position.x) # Move marker to front right

	elif velocity.x < 0:
		animated_sprite.flip_h = true
		var hand_marker = get_node_or_null("HandMarker")
		if hand_marker and hand_marker.position.x > 0:
			hand_marker.position.x = -abs(hand_marker.position.x) # Mirror marker to front left
