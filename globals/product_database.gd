extends Node

const DISPLAY_PLANTS: Array[PlantResource] = [
	PlantDatabase.A,
	PlantDatabase.B,
	PlantDatabase.C,
	PlantDatabase.AB,
	PlantDatabase.BC,
	PlantDatabase.CA,
]


func get_all_products() -> Array[ProductResource]:
	var products: Array[ProductResource] = []
	for plant: PlantResource in DISPLAY_PLANTS:
		if plant.product != null:
			products.append(plant.product)
	return products
