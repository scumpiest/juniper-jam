extends Camera2D

@export var target: Node2D


func _ready() -> void:
	enabled = true


func _process(_delta: float) -> void:
	if target != null:
		global_position = target.global_position
