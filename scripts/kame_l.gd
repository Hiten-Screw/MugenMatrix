class_name kame_l
extends Area2D

@export var damage_per_tick: float = 2.0
@export var lifetime: float = 1.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var direction: Vector2 = Vector2.RIGHT

func setup(spawn_position: Vector2, is_facing_left: bool) -> void:
	global_position = spawn_position
	
	if is_facing_left:
		direction = Vector2.LEFT
		animated_sprite.flip_h = true
		var col = get_node_or_null("CollisionShape2D")
		if col:
			col.position.x = -abs(col.position.x)
	else:
		direction = Vector2.RIGHT
		animated_sprite.flip_h = false
		var col = get_node_or_null("CollisionShape2D")
		if col:
			col.position.x = abs(col.position.x)

func _ready() -> void:
	animated_sprite.play("kame_l")
	
	body_entered.connect(_on_body_entered)
	
	get_tree().create_timer(lifetime).timeout.connect(queue_free)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		return
		
	if body.has_method("take_hit"):
		body.take_hit(damage_per_tick, "special")
