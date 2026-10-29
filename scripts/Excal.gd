class_name Excal
extends Area2D

@export var lifetime: float = 0.9

var damage: float = 0.0
var source_player_id: int = 1
var source_player: Player
var attack_id: StringName = &"projectile"
var hit_targets: Dictionary = {}

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func setup(
	spawn_position: Vector2,
	facing_left: bool,
	attack_damage: float,
	attacker: Player,
	source_attack_id: StringName = &"projectile"
) -> void:
	global_position = spawn_position
	damage = attack_damage
	source_player = attacker
	source_player_id = attacker.player_id
	attack_id = source_attack_id
	if damage <= 0.0:
		return

	collision_layer = 8 if source_player_id == 2 else 2
	collision_mask = 4 if source_player_id == 2 else 16
	var collision_shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(360.0, 100.0)
	collision_shape.shape = rectangle
	collision_shape.position = Vector2(-180.0 if facing_left else 180.0, -85.0)
	add_child(collision_shape)

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	if animated_sprite.sprite_frames.has_animation(&"default"):
		animated_sprite.play(&"default")
	get_tree().create_timer(lifetime).timeout.connect(queue_free)

func _on_area_entered(other_area: Area2D) -> void:
	var target_player := other_area.owner as Player
	if not target_player or target_player.player_id == source_player_id:
		return

	var target_id := target_player.get_instance_id()
	if hit_targets.has(target_id):
		return
	hit_targets[target_id] = true
	target_player.take_hit(damage, "special", source_player, attack_id)
