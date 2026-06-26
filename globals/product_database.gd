extends Node

@export var products: Array[ProductResource] = [
	preload("res://resources/products/A.tres"),
	preload("res://resources/products/B.tres"),
	preload("res://resources/products/C.tres"),
	preload("res://resources/products/AB.tres"),
	preload("res://resources/products/BC.tres"),
	preload("res://resources/products/CA.tres"),
]


func get_all_products() -> Array[ProductResource]:
	return products
