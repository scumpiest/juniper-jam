extends CanvasLayer


func _on_play_button_pressed() -> void:
	LevelTransition.change_scene_to("res://scenes/main.tscn")



func _on_options_button_pressed() -> void:
	LevelTransition.change_scene_to("res://scenes/Menus/settings_menu.tscn")




func _on_exit_button_pressed() -> void:
	get_tree().quit()
