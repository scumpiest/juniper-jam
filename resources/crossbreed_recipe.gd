extends Resource
class_name CrossbreedRecipe

@export var parent_a: PlantResource
@export var parent_b: PlantResource
@export var result: PlantResource


func matches(a: PlantResource, b: PlantResource) -> bool:
	return (parent_a == a and parent_b == b) or (parent_a == b and parent_b == a)
