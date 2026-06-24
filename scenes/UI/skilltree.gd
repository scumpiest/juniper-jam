extends Panel

@onready var _close_button: Button = $CloseButton
@onready var _skill_nodes: Control = $MarginContainer/ClipContainer/TreeCanvas/SkillNodes

var _blocked_ui: Array[Dictionary] = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP
	get_tree().paused = true
	_block_canvas_ui(true)
	if GlobalData.player_node:
		GlobalData.player_node.set_can_move(false)
	_close_button.pressed.connect(_on_close_pressed)
	for child in _skill_nodes.get_children():
		if child is UpgradeNode:
			child.unlocked.connect(_on_node_unlocked)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("skill_tree"):
		close()
		get_viewport().set_input_as_handled()


func _exit_tree() -> void:
	_block_canvas_ui(false)
	if GlobalData.player_node:
		GlobalData.player_node.set_can_move(true)
	if get_tree().paused:
		get_tree().paused = false


func _block_canvas_ui(blocked: bool) -> void:
	var canvas := get_parent()
	if canvas == null:
		return

	if blocked:
		_blocked_ui.clear()
		for child in canvas.get_children():
			if child == self or not child is Control:
				continue
			var control := child as Control
			_blocked_ui.append({"control": control, "mouse_filter": control.mouse_filter})
			control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	else:
		for entry in _blocked_ui:
			var control: Control = entry["control"]
			if is_instance_valid(control):
				control.mouse_filter = entry["mouse_filter"]
		_blocked_ui.clear()


func _on_node_unlocked() -> void:
	for child in _skill_nodes.get_children():
		if child is UpgradeNode:
			child.refresh_visual()


func close() -> void:
	queue_free()


func _on_close_pressed() -> void:
	close()
