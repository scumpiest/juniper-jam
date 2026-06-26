extends Resource

class_name PlantResource

# Unique identifier for the plant
@export var id: StringName = &""

@export var plant_name: String = ""
# Textures for the plant stages
@export var initial_stage: AtlasTexture
@export var growing_stage: AtlasTexture
@export var almost_stage: AtlasTexture
@export var mature_stage: AtlasTexture

@export var product: ProductResource
@export var seed_item: SeedResource
@export var product_amount: int = 1
@export var seed_amount: int = 2
@export var grow_speed: float = 0.6


func get_stage_texture(stage: int) -> AtlasTexture:
	match stage:
		0:
			return initial_stage
		1:
			return growing_stage
		2:
			return almost_stage
		3:
			return mature_stage
		_:
			return null
