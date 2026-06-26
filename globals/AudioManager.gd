extends Node

var BACKGROUND_AUDIO_NODE : AudioStreamPlayer = null
var gameplay_music = load("res://assets/Music/gameplay_loop.ogg")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	BACKGROUND_AUDIO_NODE = AudioStreamPlayer.new()
	BACKGROUND_AUDIO_NODE.stream = load("res://assets/Music/Menu_loop.ogg")
	BACKGROUND_AUDIO_NODE.autoplay = true
	BACKGROUND_AUDIO_NODE.bus = "Music"
	AudioServer.set_bus_volume_db(2, -10)
	add_child(BACKGROUND_AUDIO_NODE)

func change_music_to_gameplay():
	BACKGROUND_AUDIO_NODE.stream = gameplay_music
	BACKGROUND_AUDIO_NODE.play()
