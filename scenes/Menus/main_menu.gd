extends CanvasLayer


func _on_play_button_pressed() -> void:
	LevelTransition.change_scene_to("res://scenes/main.tscn")
