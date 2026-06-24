extends CharacterBody2D

@export var speed: float = 200.0
@export var water_amount: float = 100.0
@export var max_water_amount: float = 100.0
@export var min_water_amount: float = 0.0
@export var water_step: float = 1.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _harvest_area: Area2D = $HarvestArea
@onready var inventory_ui: CanvasLayer = $InventoryUI
@onready var magnetic_area: CollisionShape2D = $ItemCollectionArea/CollisionShape2D
@onready var foot_step_sound: AudioStreamPlayer = $FootStepSound

var _can_move: bool = true

var _overlapping_crops: Array[Area2D] = []

signal water_adjusted
signal plant_requested


func _ready() -> void:
	GlobalData.set_player_refrence(self)
	_harvest_area.area_entered.connect(_on_crop_entered)
	_harvest_area.area_exited.connect(_on_crop_exited)

	#set value for magnetic area range
	magnetic_area.shape.radius = 100


func _physics_process(_delta: float) -> void:
	if velocity and not foot_step_sound.playing:
		foot_step_sound.play()
		await foot_step_sound.finished


func try_plant_seed() -> void:
	plant_requested.emit()


func try_water() -> void:
	if water_amount <= min_water_amount:
		return
	for area in _harvest_area.get_overlapping_areas():
		if area.is_in_group("crops") and area.has_method("water"):
			area.water()
	adjust_water(water_step)


func try_harvest() -> int:
	var count := 0
	for area in _harvest_area.get_overlapping_areas():
		if (
				area.is_in_group("crops")
				and area.has_method("is_ready_to_harvest")
				and area.is_ready_to_harvest()
		):
			area.harvest()
			count += 1
	return count


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


func adjust_water(amount):
	water_amount -= amount
	water_adjusted.emit()


func refill_water() -> void:
	if water_amount >= max_water_amount:
		return
	water_amount = max_water_amount
	water_adjusted.emit()


func _on_item_collection_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("DroppedItem"):
		area.go_to_player()
