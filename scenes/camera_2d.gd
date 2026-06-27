extends Camera2D

@export var target: Node2D
@export var world_boundaries: NodePath


func _ready() -> void:
	enabled = true
	_apply_world_limits()


func _process(_delta: float) -> void:
	if target != null:
		global_position = target.global_position


func _apply_world_limits() -> void:
	if world_boundaries.is_empty():
		return
	var bounds_node := get_node_or_null(world_boundaries)
	if bounds_node == null:
		return
	var inner := _compute_inner_bounds(bounds_node)
	if inner.size.x <= 0.0 or inner.size.y <= 0.0:
		return
	limit_left = int(inner.position.x)
	limit_top = int(inner.position.y)
	limit_right = int(inner.end.x)
	limit_bottom = int(inner.end.y)
	limit_smoothed = position_smoothing_enabled


func _compute_inner_bounds(bounds_node: Node) -> Rect2:
	var rects: Array[Rect2] = []
	for child in bounds_node.get_children():
		var collision := child.get_node_or_null("CollisionShape2D") as CollisionShape2D
		if collision == null or not collision.shape is RectangleShape2D:
			continue
		rects.append(_get_collision_global_rect(collision))

	if rects.is_empty():
		return Rect2()

	var center := Vector2.ZERO
	for rect: Rect2 in rects:
		center += rect.get_center()
	center /= rects.size()

	var inner_left: float
	var inner_right: float
	var inner_top: float
	var inner_bottom: float
	var has_left := false
	var has_right := false
	var has_top := false
	var has_bottom := false

	for rect: Rect2 in rects:
		if rect.size.x < rect.size.y:
			if rect.get_center().x < center.x:
				inner_left = rect.end.x if not has_left else maxf(inner_left, rect.end.x)
				has_left = true
			else:
				if not has_right:
					inner_right = rect.position.x
				else:
					inner_right = minf(inner_right, rect.position.x)
				has_right = true
		else:
			if rect.get_center().y < center.y:
				inner_top = rect.end.y if not has_top else maxf(inner_top, rect.end.y)
				has_top = true
			else:
				if not has_bottom:
					inner_bottom = rect.position.y
				else:
					inner_bottom = minf(inner_bottom, rect.position.y)
				has_bottom = true

	if not (has_left and has_right and has_top and has_bottom):
		return Rect2()

	return Rect2(
		inner_left,
		inner_top,
		inner_right - inner_left,
		inner_bottom - inner_top,
	)


func _get_collision_global_rect(collision: CollisionShape2D) -> Rect2:
	var size := (collision.shape as RectangleShape2D).size
	var half := size / 2.0
	return Rect2(collision.global_position - half, size)
