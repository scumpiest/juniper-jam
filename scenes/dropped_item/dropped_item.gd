extends Area2D
class_name DroppedItem

var product: ProductResource
var seed_item: SeedResource

@onready var _sprite: Sprite2D = $Sprite2D


func setup_product(product_data: ProductResource) -> void:
	product = product_data
	if is_node_ready():
		_update_sprite()


func setup_seed(seed_data: SeedResource) -> void:
	seed_item = seed_data
	if is_node_ready():
		_update_sprite()


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_update_sprite()


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		_collect()


func _collect() -> void:
	if product != null:
		GlobalData.add_product(product)
	elif seed_item != null:
		GlobalData.add_seed(seed_item)
	queue_free()


func _update_sprite() -> void:
	if not is_node_ready():
		return
	if product != null:
		_sprite.texture = product.icon
	elif seed_item != null:
		_sprite.texture = seed_item.icon
