extends Camera2D

@export_range(0.1, 4.0, 0.05) var close_zoom := 1.2
@export_range(0.1, 4.0, 0.05) var maximum_zoom_out := 0.7
@export_range(0.0, 0.5, 0.01) var horizontal_margin := 0.1
@export_range(0.1, 10.0, 0.1) var zoom_speed := 3.0
@export_node_path("CollisionShape2D") var left_wall_path: NodePath
@export_node_path("CollisionShape2D") var right_wall_path: NodePath

@onready var _player_one: Player = get_parent() as Player
@onready var _player_two: Player = get_node("../../Player2") as Player
@onready var _left_wall: CollisionShape2D = get_node(left_wall_path) as CollisionShape2D
@onready var _right_wall: CollisionShape2D = get_node(right_wall_path) as CollisionShape2D

func _ready() -> void:
	zoom = Vector2.ONE * close_zoom
	limit_enabled = true
	limit_smoothed = false
	limit_bottom = 0

func _physics_process(delta: float) -> void:
	var left_edge := _get_vertical_boundary_x(_left_wall)
	var right_edge := _get_vertical_boundary_x(_right_wall)
	if left_edge > right_edge:
		push_error("Arena camera wall paths are reversed: the left wall is right of the right wall.")
		set_physics_process(false)
		return

	limit_left = ceili(left_edge)
	limit_right = floori(right_edge)

	var viewport_size := get_viewport_rect().size
	var player_distance := absf(_player_two.global_position.x - _player_one.global_position.x)
	var required_zoom := close_zoom
	if player_distance > 0.0:
		required_zoom = minf(close_zoom, (viewport_size.x * (1.0 - horizontal_margin * 2.0)) / player_distance)
	var target_zoom := clampf(required_zoom, maximum_zoom_out, close_zoom)
	var zoom_amount := 1.0 - exp(-zoom_speed * delta)
	var next_zoom := lerpf(zoom.x, target_zoom, zoom_amount)
	zoom = Vector2.ONE * next_zoom

	var half_view_width := viewport_size.x / (2.0 * zoom.x)
	var left_camera_center := left_edge + half_view_width
	var right_camera_center := right_edge - half_view_width
	var players_center := (_player_one.global_position.x + _player_two.global_position.x) * 0.5
	var camera_x := players_center
	if left_camera_center <= right_camera_center:
		camera_x = clampf(camera_x, left_camera_center, right_camera_center)
	else:
		camera_x = (left_edge + right_edge) * 0.5

	global_position = Vector2(camera_x, -viewport_size.y / (2.0 * zoom.y))

func _get_vertical_boundary_x(wall: CollisionShape2D) -> float:
	var shape := wall.shape as WorldBoundaryShape2D
	if shape == null:
		push_error("Arena camera wall path must reference a WorldBoundaryShape2D.")
		return wall.global_position.x

	var normal := Vector2.UP.rotated(wall.global_rotation)
	return (wall.global_position + normal * shape.distance).x
