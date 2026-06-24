extends Node2D

@export var ground_area: TileMapLayer
@export var plant_scene: PackedScene
@export var player: CharacterBody2D


func _ready() -> void:
	if player:
		player.plant_requested.connect(place_plant)


func place_plant() -> void:
	if player == null or GlobalData.plant_selected == null:
		return

	var tile: Vector2i = ground_area.get_tile_from_global(player.global_position)
	spread_seeds(tile)


func spread_seeds(center_tile: Vector2i) -> void:
	for x in range(-1, 2):
		for y in range(-1, 2):
			var target_tile := center_tile + Vector2i(x, y + 1)

			if ground_area.can_plant_first_seed(target_tile):
				_spawn_plant(target_tile, GlobalData.plant_selected)
			else:
				var existing: Node = ground_area.get_plant_at(target_tile)
				if existing != null and existing.has_method("try_crossbreed_with"):
					existing.try_crossbreed_with(GlobalData.plant_selected)


func _spawn_plant(tile: Vector2i, plant_data: PlantResource) -> void:
	var plant := plant_scene.instantiate()
	plant.position = ground_area.get_global_from_tile(tile)
	ground_area.add_child(plant)
	ground_area.occupied_tiles[tile] = plant
	if plant.has_method("setup"):
		plant.setup(plant_data, tile)
