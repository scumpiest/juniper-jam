extends Node

# Add new plants here
const A: PlantResource = preload("res://resources/plants/A.tres")
const B: PlantResource = preload("res://resources/plants/B.tres")
const C: PlantResource = preload("res://resources/plants/C.tres")
const AB: PlantResource = preload("res://resources/plants/AB.tres")
const BC: PlantResource = preload("res://resources/plants/BC.tres")
const CA: PlantResource = preload("res://resources/plants/CA.tres")
const RECIPE_AB: CrossbreedRecipe = preload("res://resources/crossbreed_recipes/AB.tres")
const RECIPE_BC: CrossbreedRecipe = preload("res://resources/crossbreed_recipes/BC.tres")
const RECIPE_CA: CrossbreedRecipe = preload("res://resources/crossbreed_recipes/CA.tres")

var _plants_by_id: Dictionary = {}
var _recipes: Array[CrossbreedRecipe] = []


func _ready() -> void:
	# Add new plants here
	for plant: PlantResource in [A, B, C, AB, BC, CA]:
		_plants_by_id[plant.id] = plant
	_recipes = [RECIPE_AB, RECIPE_BC, RECIPE_CA]


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
