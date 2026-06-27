extends Control

func _ready() -> void:
	visible = true
	get_tree().paused = true

func _on_close_button_pressed() -> void:
	get_tree().paused = false
	queue_free()

func reset_scene():
	get_tree().paused = false 
