extends CanvasLayer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	AudioServer.set_bus_volume_db(2, -100)
	animation_player.play("scene_2")

func change_to_menu():
	LevelTransition.change_scene_to("res://scenes/Menus/main_menu.tscn")
