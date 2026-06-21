extends Area2D

const FINAL_STAGE := 2

@export var data: PlantResource

var _current_stage: int = 0
var _grow_timer: float = 0.0
var _tile: Vector2i

@onready var _sprite: Sprite2D = $Sprite2D


func setup(plant_data: PlantResource, tile: Vector2i) -> void:
	data = plant_data
	_tile = tile
	_current_stage = 0
	_grow_timer = 0.0
	_update_sprite()


func _ready() -> void:
	if data != null:
		_update_sprite()


func _process(delta: float) -> void:
	if data == null or _current_stage >= FINAL_STAGE:
		return

	_grow_timer += delta
	if _grow_timer >= data.grow_speed:
		_grow_timer = 0.0
		_current_stage += 1
		_update_sprite()


func harvest() -> void:
	if data == null:
		return

	var ground := get_parent()
	if ground != null and ground.has_method("free_tile"):
		ground.free_tile(self)

	GlobalData.add_harvest(data)
	queue_free()


func _update_sprite() -> void:
	if data == null:
		return
	_sprite.texture = data.get_stage_texture(_current_stage)
