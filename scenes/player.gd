extends CharacterBody2D

@export var speed: float = 200.0

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
	if event.is_action_pressed("harvest"):
		_try_harvest()


func _try_harvest() -> void:
	for area in _harvest_area.get_overlapping_areas():
		if area.is_in_group("crops") and area.has_method("harvest"):
			area.harvest()


func _on_crop_entered(area: Area2D) -> void:
	if area.is_in_group("crops"):
		#print("Crop entered: ", area.name, " - ", _overlapping_crops.size())
		_overlapping_crops.append(area)


func _on_crop_exited(area: Area2D) -> void:
	_overlapping_crops.erase(area)
