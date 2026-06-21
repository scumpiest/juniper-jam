extends Node

const TILE_SIZE = 32

var plant_selected: PlantResource
var slot_1: PlantResource
var slot_2: PlantResource
var harvest_counts: Dictionary = { }


func _ready() -> void:
	slot_1 = PlantDatabase.WHEAT
	slot_2 = PlantDatabase.TOMATO
	plant_selected = slot_1


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("slot_1"):
		plant_selected = slot_1
	elif event.is_action_pressed("slot_2"):
		plant_selected = slot_2


func add_harvest(plant: PlantResource) -> void:
	if plant == null:
		return
	harvest_counts[plant.id] = harvest_counts.get(plant.id, 0) + 1
