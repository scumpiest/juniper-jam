extends Area2D

var selected : bool = false
var seed_type = 2


func _physics_process(delta: float) -> void:
	if selected:
		global_position = lerp(global_position,get_global_mouse_position(), 100 * delta)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			selected = false



func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if Input.is_action_just_pressed("left_click"):
		GlobalData.plant_selected = seed_type
		selected = true
