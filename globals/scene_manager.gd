extends Node

const MAIN := "res://scenes/main.tscn"
const SKILLTREE := "res://scenes/UI/skilltree.tscn"


func change_scene(path: String) -> void:
	get_tree().change_scene_to_file(path)


func go_to_main() -> void:
	change_scene(MAIN)


func go_to_skilltree() -> void:
	change_scene(SKILLTREE)
