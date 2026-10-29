class_name AttackDefinition
extends Resource

enum CostResource {
	NONE,
	HP,
	SP,
	MP
}

@export var move_id: StringName
@export var animation_name: StringName
@export var animation_player_name: StringName
@export var animation_player_left_name: StringName
@export var duration: float = 0.5
@export var damage: float = 0.0
@export var cost_resource: CostResource = CostResource.NONE
@export_range(0.0, 100000.0, 0.1) var cost: float = 0.0
@export_range(0.0, 3600.0, 0.1) var cooldown: float = 0.0
@export var attack_type: StringName = &"light"
@export var mirrors_hitbox_to_facing: bool = true
@export var enable_hitbox_on_start: bool = false
@export var dash_start_time: float = 0.0
@export var dash_duration: float = 0.0
@export var dash_speed: float = 0.0
@export var combo_input: StringName
@export var cancel_input: StringName
@export var cancel_slot: StringName
@export var cancel_after: float = -1.0
@export_range(-1.0, 30.0, 0.01) var projectile_spawn_time: float = -1.0
@export var projectile_damage: float = 0.0
