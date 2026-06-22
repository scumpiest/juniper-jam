extends CharacterBody2D

@export var speed: float = 200.0
@export var spin_acceleration: float = 400.0
@export var max_spin_speed: float = 1000.0
@export var spin_speed_multiplier: float = 1.5
@export var spin_duration: float = 1.2
@export var spin_cooldown_time: float = 2.0
@export var rotation_reset_speed: float = 720.0
@export var movement_acceleration: float = 400.0
@export var movement_deceleration: float = 600.0

@onready var _harvest_area: Area2D = $HarvestArea
@onready var inventory_ui: CanvasLayer = $InventoryUI

var _can_move: bool = true
var _spin_speed: float = 0.0
var _is_spinning: bool = false
var _is_resetting_rotation: bool = false
var _spin_time_left: float = 0.0
var _cooldown_left: float = 0.0

var _overlapping_crops: Array[Area2D] = []


func _ready() -> void:
	GlobalData.set_player_refrence(self)
	_harvest_area.area_entered.connect(_on_crop_entered)
	_harvest_area.area_exited.connect(_on_crop_exited)


func _process(_delta: float) -> void:
	#var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	#if _can_move:
	#	velocity = direction * speed
	#move_and_slide()
	pass

func _unhandled_input(event: InputEvent) -> void:
	#if _can_move:
		#if event.is_action_pressed("harvest"):
			#_try_harvest()
		#if event.is_action_pressed("water"):
		#	_try_water()
	if event.is_action_pressed("inventory"):
		inventory_ui.visible = !inventory_ui.visible
		get_tree().paused = !get_tree().paused
		_can_move = !_can_move
	#if _can_move and event.is_action_pressed("spin"):
	#	_start_spin()
	#if _can_move and event.is_action_released("spin"):
	#	_stop_spin()


func _start_spin() -> void:
	if _cooldown_left > 0.0 or _is_spinning or _is_resetting_rotation:
		return

	_is_spinning = true
	_spin_speed = 0.0
	_spin_time_left = spin_duration


func _stop_spin() -> void:
	if _is_spinning:
		_end_spin()


func _end_spin() -> void:
	_is_spinning = false
	_spin_speed = 0.0
	_cooldown_left = spin_cooldown_time
	_start_rotation_reset()


func _start_rotation_reset() -> void:
	if absf(rotation_degrees) < 0.5:
		rotation_degrees = 0.0
		return
	_is_resetting_rotation = true


func _try_water() -> void:
	for area in _harvest_area.get_overlapping_areas():
		if area.is_in_group("crops") and area.has_method("water"):
			area.water()

func _try_harvest() -> void:
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
