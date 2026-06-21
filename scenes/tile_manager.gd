extends Node2D

@export var ground_area: TileMapLayer
@export var plant_scene: PackedScene
@export var player: CharacterBody2D


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("plant_seeds"):
		place_plant()


func place_plant() -> void:
	if player == null or GlobalData.plant_selected == null:
		return

	var tile: Vector2i = ground_area.get_tile_from_global(player.global_position)
	spread_seeds(tile)


func spread_seeds(center_tile: Vector2i) -> void:
	# Check all tiles in a 3x3 grid around the center tile
	for x in range(-1, 2):
		for y in range(-1, 2):
			var target_tile := center_tile + Vector2i(x, y + 1)

			if ground_area.is_tile_empty(target_tile):
				var plant := plant_scene.instantiate()
				plant.position = ground_area.get_global_from_tile(target_tile)
				ground_area.add_child(plant)
				ground_area.occupied_tiles[target_tile] = plant
				if plant.has_method("setup"):
					plant.setup(GlobalData.plant_selected, target_tile)
