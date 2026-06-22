extends Node

const TILE_SIZE = 32

var plant_selected: PlantResource
var slot_1: PlantResource
var slot_2: PlantResource
var product_counts: Dictionary = {}
var seed_counts: Dictionary = {}
var hotbar_slots: Array = [null, null, null, null]

var player_node : Node = null

signal inventory_updated

const HOTBAR_ITEM_SLOTS := 4


func _ready() -> void:
	slot_1 = PlantDatabase.WHEAT
	slot_2 = PlantDatabase.TOMATO
	plant_selected = slot_1


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("slot_1"):
		plant_selected = slot_1
	elif event.is_action_pressed("slot_2"):
		plant_selected = slot_2

func set_player_refrence(player):
	player_node = player

func add_product(product: ProductResource, amount: int = 1) -> void:
	if product == null:
		return
	product_counts[product.id] = product_counts.get(product.id, 0) + amount
	_add_to_hotbar(product)
	inventory_updated.emit()

func add_seed(seed_item: SeedResource, amount: int = 1) -> void:
	if seed_item == null:
		return
	seed_counts[seed_item.id] = seed_counts.get(seed_item.id, 0) + amount
	_add_to_hotbar(seed_item)
	inventory_updated.emit()


func _add_to_hotbar(item: Resource) -> void:
	for slot_item in hotbar_slots:
		if slot_item == item:
			return
	for i in HOTBAR_ITEM_SLOTS:
		if hotbar_slots[i] == null:
			hotbar_slots[i] = item
			return
