class_name Player
extends CharacterBody2D

# --- CHARACTER CONFIGURATION (Customizable per fighter in the Inspector) ---
@export var character_name: String = "Fighter"
@export var speed: float = 63.0
@export var jump_velocity: float = -700.0
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
	
	# Initialize the FSM and pass a reference of this player to all states
	state_machine.init(self)

func _unhandled_input(event: InputEvent) -> void:
	state_machine.handle_input(event)

func _process(delta: float) -> void:
	state_machine.update(delta)

func _physics_process(delta: float) -> void:
	state_machine.physics_update(delta)
	
	# FACING DIRECTION CHECK:
	# If moving right, face right (not flipped). If moving left, face left (flipped).
	if velocity.x > 0:
		animated_sprite.flip_h = false
	elif velocity.x < 0:
		animated_sprite.flip_h = true
