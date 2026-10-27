class_name StateMachine
extends Node

@export var initial_state: State

var current_state: State
var states: Dictionary = {}

func init(player_ref: Player) -> void:
	states["idle"] = Idle.new()
	states["move"] = Move.new()
	states["jump"] = Jump.new()
	states["attack"] = Attack.new()
	states["hitstun"] = HitStun.new()
	states["block"] = Block.new()

	for state_key in states.keys():
		states[state_key].player = player_ref

	change_state("idle")

func change_state(new_state_name: String) -> void:
	var target_state = states.get(new_state_name.to_lower())
	if not target_state:
		return
	
	if current_state:
		current_state.exit()
	
	current_state = target_state
	current_state.enter()

func update(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func physics_update(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

func handle_input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)
