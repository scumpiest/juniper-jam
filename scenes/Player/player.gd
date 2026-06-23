extends CharacterBody2D

@export var speed: float = 200.0

@onready var _harvest_area: Area2D = $HarvestArea
@onready var inventory_ui: CanvasLayer = $InventoryUI

var _can_move: bool = true

var _overlapping_crops: Array[Area2D] = []


func _ready() -> void:
	GlobalData.set_player_refrence(self)
	_harvest_area.area_entered.connect(_on_crop_entered)
	_harvest_area.area_exited.connect(_on_crop_exited)


func _physics_process(_delta: float) -> void:
	pass


func _unhandled_input(event: InputEvent) -> void:
	# if _can_move:
	# 	if event.is_action_pressed("harvest"):
	# 		_try_harvest()
	# 	if event.is_action_pressed("water"):
	# 		_try_water()
	if event.is_action_pressed("inventory"):
		inventory_ui.visible = !inventory_ui.visible
		get_tree().paused = !get_tree().paused
		_can_move = !_can_move


func try_water() -> void:
	for area in _harvest_area.get_overlapping_areas():
		if area.is_in_group("crops") and area.has_method("water"):
			area.water()


func try_harvest() -> void:
	for area in _harvest_area.get_overlapping_areas():
		if (
				area.is_in_group("crops")
				and area.has_method("is_ready_to_harvest")
				and area.is_ready_to_harvest()
		):
			area.harvest()

func _on_crop_entered(area: Area2D) -> void:
	if area.is_in_group("crops"):
		area.sway_animation()
		_overlapping_crops.append(area)

func _on_crop_exited(area: Area2D) -> void:
	_overlapping_crops.erase(area)


func get_can_move() -> bool:
	return _can_move


func set_can_move(value: bool) -> void:
	_can_move = value
