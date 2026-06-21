extends Node

# Add new plants here
const WHEAT: PlantResource = preload("res://resources/plants/wheat.tres")
const TOMATO: PlantResource = preload("res://resources/plants/tomato.tres")
const PUMPKIN: PlantResource = preload("res://resources/plants/pumpkin.tres")
const RECIPE_WHEAT_TOMATO: CrossbreedRecipe = preload(
	"res://resources/crossbreed_recipes/wheat_tomato_pumpkin.tres"
)

var _plants_by_id: Dictionary = {}
var _recipes: Array[CrossbreedRecipe] = []


func _ready() -> void:
	# Add new plants here
	for plant: PlantResource in [WHEAT, TOMATO, PUMPKIN]:
		_plants_by_id[plant.id] = plant
	_recipes = [RECIPE_WHEAT_TOMATO]


func get_plant(id: StringName) -> PlantResource:
	return _plants_by_id.get(id)


func get_all_plants() -> Array[PlantResource]:
	var plants: Array[PlantResource] = []
	for plant: PlantResource in _plants_by_id.values():
		plants.append(plant)
	return plants


func find_recipe(a: PlantResource, b: PlantResource) -> CrossbreedRecipe:
	for recipe: CrossbreedRecipe in _recipes:
		if recipe.matches(a, b):
			return recipe
	return null
