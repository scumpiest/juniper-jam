extends CanvasLayer

func _ready() -> void:
	AudioServer.set_bus_volume_db(2,-72)

func load_game_scene():
	LevelTransition.change_scene_to("res://scenes/main.tscn")

func tween_volume_down():
	var volume_db : float = -10

func reset_global_volume():
	AudioServer.set_bus_volume_db(2, -10)
