@tool
extends Area2D

class_name DroppedItem

@export var product: ProductResource
@export var seed_item: SeedResource

var tween : Tween

@onready var _sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var item_pickup: AudioStreamPlayer = $ItemPickup

signal target_reached


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
	collision_shape.set_deferred("disabled", true)
	await get_tree().create_timer(0.5).timeout
	collision_shape.set_deferred("disabled", false)
	



func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		item_pickup.play()
		await item_pickup.finished
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
		

func go_to_player(duration = 2.0, delay = 0.0):
	
	if tween: tween.kill()
	
	tween = create_tween()
	
	tween.tween_interval(delay)
	
	tween.tween_method(_lerp_to_target, 0.0, 1.0, duration)
	
func _lerp_to_target(progression : float):
	
	var target_position = get_tree().get_first_node_in_group("Player").global_position

	global_position = lerp(global_position, target_position, progression)
	
	if global_position.distance_to(target_position) <=  5.0:
		target_reached.emit()
		tween.kill()
