class_name State
extends Resource

var player: CharacterBody2D
var energyBall: Area2D

# Called when the state becomes active
func enter() -> void:
	pass
# Called when exiting the state
func exit() -> void:
	pass

# Called every frame (_process)
func update(_delta: float) -> void:
	pass
# Called every physics frame (_physics_process)
func physics_update(_delta: float) -> void:
	pass

# Called when unhandled input events come in (great for jumps or attacks)
func handle_input(_event: InputEvent) -> void:
	pass
