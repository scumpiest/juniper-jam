extends Node2D

const SKILLTREE_SCENE := preload("res://scenes/UI/skilltree.tscn")

@onready var _canvas_layer: CanvasLayer = $CanvasLayer


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("skill_tree") and not _is_skilltree_open():
		open_skilltree()
		get_viewport().set_input_as_handled()


func _on_skilltree_button_pressed() -> void:
	open_skilltree()


func open_skilltree() -> void:
	if _is_skilltree_open():
		return
	var skilltree := SKILLTREE_SCENE.instantiate()
	_canvas_layer.add_child(skilltree)


func _is_skilltree_open() -> bool:
	return _canvas_layer.find_child("Skilltree", false, false) != null
