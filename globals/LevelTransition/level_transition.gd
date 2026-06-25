extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var scene_to_load : String
var color_rect_tween : Tween

func change_scene_to(scene_path : String) -> void:
	scene_to_load = scene_path
	get_tree().paused = true
	animation_player.play("transition_out")
	await animation_player.animation_finished
	animation_player.play("transition_in")
	_load_new_scene()
func _load_new_scene() -> void:
	get_tree().paused = false
	get_tree().call_deferred("change_scene_to_file", scene_to_load)
