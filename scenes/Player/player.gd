extends CharacterBody2D

@export var base_speed: float = 200.0
@export var water_amount: float = 100.0
@export var base_max_water: float = 100.0
@export var max_water_amount: float = 100.0
@export var min_water_amount: float = 0.0
@export var water_step: float = 10.0
@export var water_action_duration: float = 0.30

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _harvest_area: Area2D = $HarvestArea
@onready var _harvest_collision: CollisionShape2D = $HarvestArea/CollisionShape2D
@onready var inventory_ui: CanvasLayer = $InventoryUI
@onready var magnetic_area: CollisionShape2D = $ItemCollectionArea/CollisionShape2D
@onready var hurt_box_collision: CollisionShape2D = $HurtBox/CollisionShape2D
@onready var spinning_state: SpinningState = $StateMachine/SpinningState
#audio nodes
@onready var foot_step_sound: AudioStreamPlayer = $FootStepSound
@onready var watering_sound: AudioStreamPlayer = $WateringSound

var _can_move: bool = true
var speed: float = 200.0

const BASE_MAGNET_RADIUS := 100.0
const BASE_HARVEST_SCALE := Vector2(2.0, 2.0)

var _overlapping_crops: Array[Area2D] = []

signal water_adjusted
signal plant_requested


func _ready() -> void:
	GlobalData.set_player_refrence(self)
	_harvest_area.area_entered.connect(_on_crop_entered)
	_harvest_area.area_exited.connect(_on_crop_exited)
	GlobalData.upgrades_changed.connect(_apply_upgrades)
	_apply_upgrades()


func _apply_upgrades() -> void:
	speed = GlobalData.get_move_speed(base_speed)

	var previous_max := max_water_amount
	max_water_amount = GlobalData.get_max_water(base_max_water)
	if max_water_amount > previous_max:
		water_amount += max_water_amount - previous_max
	water_amount = minf(water_amount, max_water_amount)

	if magnetic_area.shape is CircleShape2D:
		(magnetic_area.shape as CircleShape2D).radius = GlobalData.get_magnet_radius(BASE_MAGNET_RADIUS)
	_harvest_collision.scale = GlobalData.get_harvest_area_scale(BASE_HARVEST_SCALE)

	water_adjusted.emit()


func _physics_process(_delta: float) -> void:
	if velocity and not foot_step_sound.playing:
		foot_step_sound.play()
		await foot_step_sound.finished
	
	
	if spinning_state._is_spinning == true:
		hurt_box_collision.set_deferred("disabled", false)
	else:
		hurt_box_collision.set_deferred("disabled", true)


func try_plant_seed() -> void:
	plant_requested.emit()


func try_water() -> void:
	if water_amount <= min_water_amount:
		return

	for area in _harvest_area.get_overlapping_areas():
		if not watering_sound.is_playing:
			watering_sound.play()
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


func _on_hurt_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("Boss") and GlobalData.is_skill_node_unlocked(&"Final"):
		body.adjust_health(1)
