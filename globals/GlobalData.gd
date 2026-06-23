extends Node

const TILE_SIZE = 32

var plant_selected: PlantResource
var slot_1: PlantResource
var slot_2: PlantResource
var product_counts: Dictionary = { }
var seed_counts: Dictionary = { }
var hotbar_slots: Array = [null, null, null, null]

var player_node: Node = null

signal inventory_updated
signal upgrades_changed

const HOTBAR_ITEM_SLOTS := 4

var _upgrade_modifiers: Dictionary = { }
var _feature_unlocks: Dictionary = { }
var _unlocked_skill_nodes: Dictionary = { }


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


func get_upgrade_modifier(type: Upgrade.Type) -> float:
	return _upgrade_modifiers.get(type, 0.0)


func is_feature_unlocked(type: Upgrade.Type) -> bool:
	return _feature_unlocks.get(type, false)


func is_skill_node_unlocked(node_name: StringName) -> bool:
	return _unlocked_skill_nodes.get(node_name, false)


func unlock_skill_node(node_name: StringName) -> bool:
	if is_skill_node_unlocked(node_name):
		return false
	_unlocked_skill_nodes[node_name] = true
	return true


func apply_upgrade(upgrade: Upgrade) -> void:
	if upgrade == null:
		return
	match upgrade.type:
		Upgrade.Type.UNLOCK_CRAFTING, Upgrade.Type.UNLOCK_BREEDING, Upgrade.Type.UNLOCK_SPIN_HOLD:
			_feature_unlocks[upgrade.type] = true
		_:
			_upgrade_modifiers[upgrade.type] = get_upgrade_modifier(upgrade.type) + upgrade.value
	upgrades_changed.emit()
