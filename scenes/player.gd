extends CharacterBody2D

@export var speed: float = 100.0

@onready var _harvest_area: Area2D = $HarvestArea

var _overlapping_crops: Array[Area2D] = []


func _ready() -> void:
	_harvest_area.area_entered.connect(_on_crop_entered)
	_harvest_area.area_exited.connect(_on_crop_exited)


func _process(_delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed
	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("spin"):
		_try_harvest()


func _try_harvest() -> void:
	for crop in _overlapping_crops:
		if crop.has_method("harvest"):
			crop.harvest()
			return


func _on_crop_entered(area: Area2D) -> void:
	if area.is_in_group("crops"):
		_overlapping_crops.append(area)


func _on_crop_exited(area: Area2D) -> void:
	_overlapping_crops.erase(area)
