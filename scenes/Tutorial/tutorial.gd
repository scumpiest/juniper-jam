extends Control

func _ready() -> void:
	get_tree().paused = true

func _on_close_button_pressed() -> void:
	queue_free()

func reset_scene():
	get_tree().paused = false 
