class_name State
extends Resource

var player: Player

func enter() -> void:
	pass

func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func handle_input(_event: InputEvent) -> void:
	pass

func is_action_pressed(action: StringName) -> bool:
	return Input.is_action_pressed(player.input_action(action))

func is_action_just_pressed(action: StringName) -> bool:
	return Input.is_action_just_pressed(player.input_action(action))

func get_axis(negative_action: StringName, positive_action: StringName) -> float:
	return Input.get_axis(player.input_action(negative_action), player.input_action(positive_action))
