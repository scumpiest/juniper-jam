extends Node

var BACKGROUND_AUDIO_NODE : AudioStreamPlayer = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	BACKGROUND_AUDIO_NODE = AudioStreamPlayer.new()
	BACKGROUND_AUDIO_NODE.stream = load("res://assets/Gameplay_1.mp3")
	BACKGROUND_AUDIO_NODE.autoplay = true
	BACKGROUND_AUDIO_NODE.bus = "Music"
	AudioServer.set_bus_volume_db(2, -10)
	add_child(BACKGROUND_AUDIO_NODE)
