extends Node2D

@export var ground_area: TileMapLayer
@export var plant_scene: PackedScene
@export var player: CharacterBody2D


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("plant_seeds"):
		place_plant()


func place_plant() -> void:
	if player == null:
		return

	var tile: Vector2i = ground_area.get_tile_from_global(player.global_position)
	if ground_area.is_tile_empty(tile):
		var plant := plant_scene.instantiate()
		plant.position = ground_area.get_global_from_tile(tile)
		ground_area.add_child(plant)
		ground_area.occupied_tiles[tile] = plant
