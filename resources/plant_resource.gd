extends Resource

class_name PlantResource

# Unique identifier for the plant
@export var id: StringName = &""

@export var plant_name: String = ""
# Textures for the plant stages
@export var initial_stage: AtlasTexture
@export var growing_stage: AtlasTexture
@export var mature_stage: AtlasTexture

# TODO: Add a way to set the grow speed(certain actions like watering or fertilizing is required to continue growing)
@export var grow_speed: float = 0.6


func get_stage_texture(stage: int) -> AtlasTexture:
	match stage:
		0:
			return initial_stage
		1:
			return growing_stage
		2:
			return mature_stage
		_:
			return null
