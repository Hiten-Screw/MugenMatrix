class_name Hitbox
extends Area2D

@export var damage: float = 10.0
@export var attack_type: String = "light"

var hit_targets: Dictionary = {}

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func begin_attack() -> void:
	hit_targets.clear()

func _on_area_entered(other_area: Area2D) -> void:
	var owner_player = owner as Player
	var target_player = other_area.owner as Player
	
	if target_player and target_player != owner_player:
		var target_id = target_player.get_instance_id()
		if hit_targets.has(target_id):
			return
		hit_targets[target_id] = true
		target_player.take_hit(damage, attack_type)
