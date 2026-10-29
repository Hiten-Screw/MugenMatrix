class_name Hitbox
extends Area2D

@export var damage: float = 10.0
@export var attack_type: String = "light"

var attack_id: StringName
var hit_targets: Dictionary = {}
var attack_active: bool = false

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _physics_process(_delta: float) -> void:
	if not attack_active:
		return
	for other_area in get_overlapping_areas():
		_try_hit_target(other_area)

func begin_attack() -> void:
	hit_targets.clear()
	attack_active = true

func end_attack() -> void:
	attack_active = false

func _on_area_entered(other_area: Area2D) -> void:
	if not attack_active:
		return

	_try_hit_target(other_area)

func _try_hit_target(other_area: Area2D) -> void:
	var owner_player = owner as Player
	var target_player = other_area.owner as Player
	
	if target_player and target_player != owner_player:
		var target_id = target_player.get_instance_id()
		if hit_targets.has(target_id):
			return
		hit_targets[target_id] = true
		target_player.take_hit(damage, attack_type, owner_player, attack_id)
