extends TileMapLayer

# The size of the map in tiles
@export var map_size: Vector2i = Vector2i(5, 5)

var bounds: Rect2i

# Stores what is on each tile. Key: Vector2i (tile), Value: Node2D (the object)
var occupied_tiles: Dictionary = {}

func _ready() -> void:
	bounds = Rect2i(Vector2i.ZERO, map_size)


# Converts a global position to a tile position
func get_tile_from_global(global: Vector2) -> Vector2i:
	return local_to_map(to_local(global))


# Converts a tile position to a global position
func get_global_from_tile(tile: Vector2i) -> Vector2:
	return to_global(map_to_local(tile))


# Checks if the tile coordinates are within the bounds of the grid
func is_tile_in_bounds(tile_coords: Vector2i) -> bool:
	return bounds.has_point(tile_coords)


# Checks if the tile is empty
func is_tile_empty(tile_coords: Vector2i) -> bool:
	return is_tile_in_bounds(tile_coords) and not occupied_tiles.has(tile_coords)


func free_tile(plant: Node2D) -> void:
	for tile: Vector2i in occupied_tiles:
		if occupied_tiles[tile] == plant:
			occupied_tiles.erase(tile)
			return