extends Area2D

const FINAL_STAGE := 3

@export var dropped_item_scene: PackedScene
@export var data: PlantResource

var _current_stage: int = 0
var _grow_timer: float = 0.0
var _tile: Vector2i
var _first_seed: PlantResource
var _is_crossbred: bool = false
var _is_watered : bool = false

var tween : Tween

@onready var _sprite: Sprite2D = $Sprite2D
@onready var crop_rustle: AudioStreamPlayer = $CropRustle


func setup(plant_data: PlantResource, tile: Vector2i) -> void:
	_first_seed = plant_data
	data = plant_data
	_tile = tile
	_is_crossbred = false
	_reset_growth()
	if is_node_ready():
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
	
	if _is_watered :
		_grow_timer += delta
		if _grow_timer >= data.grow_speed:
			_grow_timer = 0.0
			_current_stage += 1
			_update_sprite()


func water() -> void:
	if not _is_watered:
		_is_watered = true


func is_ready_to_harvest() -> bool:
	return _current_stage >= FINAL_STAGE


func harvest() -> void:
	if data == null or _current_stage < FINAL_STAGE:
		return

	var ground := get_parent()
	var drop_position := global_position
	if ground != null and ground.has_method("free_tile"):
		ground.free_tile(self)

	var drop_parent := get_tree().current_scene
	_spawn_drops(drop_position, drop_parent)
	queue_free()


func _spawn_drops(world_position: Vector2, parent: Node) -> void:
	if parent == null or data == null:
		return

	if data.product != null:
		for i in data.product_amount:
			var product_offset := Vector2(-6 + i * 4, 0)
			_spawn_product_drop(parent, world_position + product_offset, data.product)
	if data.seed_item != null:
		var seed_count := data.seed_amount + int(GlobalData.get_upgrade_modifier(Upgrade.Type.SEED_YIELD))
		for i in seed_count:
			var seed_offset := Vector2(6, -4 + i * 4)
			_spawn_seed_drop(parent, world_position + seed_offset, data.seed_item)


func _spawn_product_drop(
	parent: Node, world_position: Vector2, product_data: ProductResource
) -> void:
	var drop := dropped_item_scene.instantiate()
	parent.add_child(drop)
	drop.global_position = world_position + Vector2(randf_range(0, 20), randf_range(0,20)) #remove_vector 2 part if u want to
	drop.setup_product(product_data)


func _spawn_seed_drop(parent: Node, world_position: Vector2, seed_data: SeedResource) -> void:
	var drop := dropped_item_scene.instantiate()
	parent.add_child(drop)
	drop.global_position = world_position  + Vector2(randf_range(0, 20), randf_range(0,20)) #remove_vector 2 part if u want to
	drop.setup_seed(seed_data)


func _update_sprite() -> void:
	if not is_node_ready() or data == null:
		return
	_sprite.texture = data.get_stage_texture(_current_stage)
	_is_watered = false


func _reset_growth() -> void:
	_current_stage = 0
	_grow_timer = 0.0


func _apply_crossbreed(result: PlantResource) -> void:
	data = result
	_first_seed = null
	_is_crossbred = true
	_reset_growth()
	_update_sprite()
	
#handle sway animation

func sway_animation():
	reset_tween()
	tween.tween_property(_sprite, "rotation_degrees", 15 ,0.1).set_trans(Tween.TRANS_SINE)
	tween.tween_property(_sprite, "scale", Vector2(1.1, 0.9),0.1).set_trans(Tween.TRANS_SINE)
	
	tween.tween_callback(crop_rustle.play)
	tween.tween_property(_sprite, "rotation_degrees", -8.0, 0.1)
	tween.tween_property(_sprite, "scale", Vector2(0.9, 1.1), 0.1)
	
	tween.tween_property(_sprite, "rotation_degrees", 0.0, 0.15).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(_sprite, "scale", Vector2(1, 1), 0.15).set_trans(Tween.TRANS_BOUNCE)
	
	

func reset_tween():
	if tween:
		tween.kill()
	tween = create_tween()
	
