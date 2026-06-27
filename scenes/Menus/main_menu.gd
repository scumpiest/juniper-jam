extends CanvasLayer
@onready var button_hover: AudioStreamPlayer = $ButtonHover
@onready var button_clicked: AudioStreamPlayer = $ButtonClicked


func _ready() -> void:
	AudioServer.set_bus_volume_db(2,-15)

func _on_play_button_pressed() -> void:
	button_clicked.play()
	await button_clicked.finished
	LevelTransition.change_scene_to("res://scenes/Cutscenes/cutscene.tscn")



func _on_options_button_pressed() -> void:
	button_clicked.play()
	await button_clicked.finished
	LevelTransition.change_scene_to("res://scenes/Menus/settings_menu.tscn")



func _on_exit_button_pressed() -> void:
	get_tree().quit()



func _on_mouse_entered() -> void:
	button_hover.play()
