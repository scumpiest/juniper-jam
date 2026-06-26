extends CanvasLayer

func _ready() -> void:
	AudioManager.BACKGROUND_AUDIO_NODE.stream_paused = true

func load_game_scene():
	LevelTransition.change_scene_to("res://scenes/main.tscn")

func tween_volume_down():
	var volume_db : float = -10
