extends Control

@export var min_zoom: float = 0.5
@export var max_zoom: float = 2.5
@export var zoom_step: float = 1.1
@export var initial_zoom: float = 2.0
@export var offset_y: float = 750.0

var _dragging := false
var _drag_start := Vector2.ZERO
var _canvas_start := Vector2.ZERO


func _ready() -> void:
	await get_tree().process_frame
	scale = Vector2.ONE * clampf(initial_zoom, min_zoom, max_zoom)
	_center_in_view()


func _center_in_view() -> void:
	var viewport := get_parent() as Control
	if viewport == null:
		return
	var content_size := size * scale
	position = (viewport.size - content_size) / 2.0 + Vector2(0, offset_y)


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
