extends Area2D

const FINAL_STAGE := 2

@export var data: PlantResource

var _current_stage: int = 0
var _grow_timer: float = 0.0
var _tile: Vector2i
var _first_seed: PlantResource
var _is_crossbred: bool = false

@onready var _sprite: Sprite2D = $Sprite2D


func setup(plant_data: PlantResource, tile: Vector2i) -> void:
	_first_seed = plant_data
	data = plant_data
	_tile = tile
	_is_crossbred = false
	_reset_growth()
	_update_sprite()


func has_first_seed_only() -> bool:
	return _first_seed != null and not _is_crossbred


func try_crossbreed_with(second: PlantResource) -> bool:
	if not has_first_seed_only():
		return false
	if _first_seed.id == second.id:
		return false
	var recipe := PlantDatabase.find_recipe(_first_seed, second)
	if recipe == null:
		return false
	_apply_crossbreed(recipe.result)
	return true


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


func _reset_growth() -> void:
	_current_stage = 0
	_grow_timer = 0.0


func _apply_crossbreed(result: PlantResource) -> void:
	data = result
	_first_seed = null
	_is_crossbred = true
	_reset_growth()
	_update_sprite()
