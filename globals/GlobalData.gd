extends Node

const TILE_SIZE = 32

var plant_selected: PlantResource
var harvest_counts: Dictionary = {}


func _ready() -> void:
	plant_selected = PlantDatabase.get_plant(&"wheat")


func add_harvest(plant: PlantResource) -> void:
	if plant == null:
		return
	harvest_counts[plant.id] = harvest_counts.get(plant.id, 0) + 1
