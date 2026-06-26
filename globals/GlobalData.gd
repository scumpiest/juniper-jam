extends Node

const TILE_SIZE = 32

var plant_selected: PlantResource
var slot_1: PlantResource
var slot_2: PlantResource
var product_counts: Dictionary = { }
var seed_counts: Dictionary = { }
var hotbar_slots: Array = [null, null, null, null, null, null]

var player_node: Node = null

signal inventory_updated
signal upgrades_changed
signal slot_selection_changed(index: int)

const HOTBAR_ITEM_SLOTS := 6
const HOTBAR_TOOL_SLOTS := 2

var selected_slot_index: int = 0

var _upgrade_modifiers: Dictionary = { }
var _feature_unlocks: Dictionary = { }
var _unlocked_skill_nodes: Dictionary = { }


func _ready() -> void:
	slot_1 = PlantDatabase.A
	slot_2 = PlantDatabase.B
	plant_selected = slot_1

	var water_tool := ToolResource.new()
	water_tool.tool_type = ToolResource.ToolType.WATER
	water_tool.display_name = "Water"
	hotbar_slots[0] = water_tool

	var harvest_tool := ToolResource.new()
	harvest_tool.tool_type = ToolResource.ToolType.HARVEST
	harvest_tool.display_name = "Harvest"
	hotbar_slots[1] = harvest_tool

	# TODO: DELETE THIS AFTER TESTING
	var a_seed := PlantDatabase.A.seed_item
	var b_seed := PlantDatabase.B.seed_item
	var c_seed := PlantDatabase.C.seed_item
	hotbar_slots[2] = a_seed
	hotbar_slots[3] = b_seed
	hotbar_slots[4] = c_seed
	seed_counts[a_seed.id] = 5
	seed_counts[b_seed.id] = 5
	seed_counts[c_seed.id] = 5


func _unhandled_input(event: InputEvent) -> void:
	for i in HOTBAR_ITEM_SLOTS:
		if event.is_action_pressed("slot_%d" % (i + 1)):
			select_slot(i)
			return

	if event.is_action_pressed("prev_slot"):
		select_slot(wrapi(selected_slot_index - 1, 0, HOTBAR_ITEM_SLOTS))
	elif event.is_action_pressed("next_slot"):
		select_slot(wrapi(selected_slot_index + 1, 0, HOTBAR_ITEM_SLOTS))


func select_slot(index: int) -> void:
	selected_slot_index = clampi(index, 0, HOTBAR_ITEM_SLOTS - 1)
	var item: Resource = hotbar_slots[selected_slot_index]
	if item is SeedResource:
		plant_selected = (item as SeedResource).get_plant()
	slot_selection_changed.emit(selected_slot_index)


func get_active_slot_item() -> Resource:
	return hotbar_slots[selected_slot_index]


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
	for i in range(HOTBAR_TOOL_SLOTS, HOTBAR_ITEM_SLOTS):
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
