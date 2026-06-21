extends Resource

class_name SeedResource

@export var id: StringName = &""
@export var seed_name: String = ""
@export var icon: AtlasTexture
@export var plant_id: StringName = &""


func get_plant() -> PlantResource:
	return PlantDatabase.get_plant(plant_id)
