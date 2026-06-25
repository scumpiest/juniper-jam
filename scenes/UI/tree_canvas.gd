extends Control

@export var min_zoom: float = 0.5
@export var max_zoom: float = 2.5
@export var zoom_step: float = 1.1
@export var initial_zoom: float = 2.0
@export var top_padding: float = 16.0

var _dragging := false
var _drag_start := Vector2.ZERO
var _canvas_start := Vector2.ZERO


func _ready() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	var viewport := get_parent() as Control
	if viewport != null and viewport.size == Vector2.ZERO:
		await viewport.resized
	scale = Vector2.ONE * clampf(initial_zoom, min_zoom, max_zoom)
	_scroll_to_deepest_unlocked_row()


func _get_focus_row_y() -> float:
	var skill_nodes := get_node_or_null("SkillNodes") as Control
	if skill_nodes == null:
		return 0.0

	var deepest_unlocked_y := -INF
	var topmost_y := INF
	var found_unlocked := false

	for child in skill_nodes.get_children():
		if child is not UpgradeNode:
			continue
		var row_y: float = skill_nodes.position.y + child.position.y
		topmost_y = minf(topmost_y, row_y)
		if child.is_unlocked or GlobalData.is_skill_node_unlocked(child.name):
			deepest_unlocked_y = maxf(deepest_unlocked_y, row_y)
			found_unlocked = true

	if found_unlocked:
		return deepest_unlocked_y
	if topmost_y != INF:
		return topmost_y
	return 0.0


func _scroll_to_deepest_unlocked_row() -> void:
	var viewport := get_parent() as Control
	if viewport == null:
		return
	var focus_row_y := _get_focus_row_y()
	position.x = (viewport.size.x - size.x * scale.x) * 0.5
	position.y = top_padding - focus_row_y * scale.y


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			_dragging = event.pressed
			if _dragging:
				_drag_start = get_global_mouse_position()
				_canvas_start = global_position
		elif event.pressed:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				_zoom_at(event.position, zoom_step)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				_zoom_at(event.position, 1.0 / zoom_step)
	elif event is InputEventMouseMotion and _dragging:
		global_position = _canvas_start + (get_global_mouse_position() - _drag_start)


func _zoom_at(local_mouse: Vector2, factor: float) -> void:
	var old_scale := scale.x
	var new_scale := clampf(old_scale * factor, min_zoom, max_zoom)
	if is_equal_approx(new_scale, old_scale):
		return
	position += local_mouse * (old_scale - new_scale)
	scale = Vector2(new_scale, new_scale)
