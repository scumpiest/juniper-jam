extends Node

@export var products: Array[ProductResource] = [
	preload("res://resources/products/wheat.tres"),
	preload("res://resources/products/tomato.tres"),
]


func get_all_products() -> Array[ProductResource]:
	return products
