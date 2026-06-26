extends Node

const TILE_SIZE = 32


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


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

# Per skill-tree tier (each node adds upgrade.value)
const UPGRADE_PER_LEVEL: Dictionary = {
	Upgrade.Type.MOVE_SPEED: 40.0, # 40 units per second
	Upgrade.Type.SPIN_SPEED: 0.3, # 0.3 multiplier
	Upgrade.Type.SPIN_DURATION: 2.0, # 2 seconds
	Upgrade.Type.SPIN_RECHARGE: 0.20, # 0.2 seconds less to recharge
	Upgrade.Type.SPIN_RADIUS: 1, # 1 unit radius
	Upgrade.Type.MAGNET_RADIUS: 25.0, # 30 units radius
	Upgrade.Type.WATER_HOLD: 50.0, # 50 water hold? maybe
	Upgrade.Type.PRODUCT_YIELD: 1.0, # 1 more product per harvest
	Upgrade.Type.SEED_YIELD: 1.0, # 1 more seed per harvest
}

const SKILLTREE_SCENE := preload("res://scenes/UI/skilltree.tscn")


func _ready() -> void:
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

	inventory_updated.emit()
	select_slot(selected_slot_index)


func _unhandled_input(event: InputEvent) -> void:
	for i in HOTBAR_ITEM_SLOTS:
		if event.is_action_pressed("slot_%d" % (i + 1)):
			select_slot(i)
			return

	if event.is_action_pressed("prev_slot"):
		select_slot(wrapi(selected_slot_index - 1, 0, HOTBAR_ITEM_SLOTS))
	elif event.is_action_pressed("next_slot"):
		select_slot(wrapi(selected_slot_index + 1, 0, HOTBAR_ITEM_SLOTS))
	elif event.is_action_pressed("debug_mode"):
		_debug_fill_products()
		_debug_unlock_all_upgrades()


func _debug_fill_products() -> void:
	for product: ProductResource in ProductDatabase.get_all_products():
		if product != null:
			product_counts[product.id] = 999
	for plant: PlantResource in ProductDatabase.DISPLAY_PLANTS:
		if plant != null and plant.seed_item != null:
			seed_counts[plant.seed_item.id] = 999
	inventory_updated.emit()


func _debug_unlock_all_upgrades() -> void:
	_upgrade_modifiers.clear()
	_feature_unlocks.clear()
	_unlocked_skill_nodes.clear()

	var skilltree: Node = SKILLTREE_SCENE.instantiate()
	var skill_nodes: Node = skilltree.get_node("MarginContainer/ClipContainer/TreeCanvas/SkillNodes")
	for child in skill_nodes.get_children():
		if child is UpgradeNode:
			var node := child as UpgradeNode
			_unlocked_skill_nodes[node.name] = true
			if node.upgrade != null:
				match node.upgrade.type:
					Upgrade.Type.UNLOCK_CRAFTING, Upgrade.Type.UNLOCK_BREEDING, Upgrade.Type.UNLOCK_SPIN_HOLD:
						_feature_unlocks[node.upgrade.type] = true
					_:
						_upgrade_modifiers[node.upgrade.type] = (
								get_upgrade_modifier(node.upgrade.type) + node.upgrade.value
						)
	skilltree.queue_free()
	upgrades_changed.emit()
	_refresh_open_skilltree()


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


func get_seed_count(seed_item: SeedResource) -> int:
	if seed_item == null:
		return 0
	return seed_counts.get(seed_item.id, 0)


func add_seed(seed_item: SeedResource, amount: int = 1) -> void:
	if seed_item == null:
		return
	seed_counts[seed_item.id] = seed_counts.get(seed_item.id, 0) + amount
	_add_to_hotbar(seed_item)
	inventory_updated.emit()


func remove_seed(seed_item: SeedResource, amount: int = 1) -> bool:
	if seed_item == null or amount <= 0:
		return false
	var current: int = seed_counts.get(seed_item.id, 0)
	if current < amount:
		return false
	var remaining: int = current - amount
	if remaining <= 0:
		seed_counts.erase(seed_item.id)
	else:
		seed_counts[seed_item.id] = remaining
	inventory_updated.emit()
	return true


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


func get_upgrade_bonus(type: Upgrade.Type) -> float:
	return get_upgrade_modifier(type) * UPGRADE_PER_LEVEL.get(type, 0.0)


func get_move_speed(base: float) -> float:
	return base + get_upgrade_bonus(Upgrade.Type.MOVE_SPEED)


func get_spin_duration(base: float) -> float:
	return base + get_upgrade_bonus(Upgrade.Type.SPIN_DURATION)


func get_spin_cooldown(base: float) -> float:
	return maxf(0.5, base - get_upgrade_bonus(Upgrade.Type.SPIN_RECHARGE))


func get_spin_speed_multiplier(base: float) -> float:
	return base + get_upgrade_bonus(Upgrade.Type.SPIN_SPEED)


func get_harvest_area_scale(base: Vector2) -> Vector2:
	return base + Vector2.ONE * get_upgrade_bonus(Upgrade.Type.SPIN_RADIUS)


func get_magnet_radius(base: float) -> float:
	return base + get_upgrade_bonus(Upgrade.Type.MAGNET_RADIUS)


func get_max_water(base: float) -> float:
	return base + get_upgrade_bonus(Upgrade.Type.WATER_HOLD)


func get_yield_bonus(type: Upgrade.Type) -> int:
	return int(get_upgrade_modifier(type))


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


func _refresh_open_skilltree() -> void:
	var tree: Node = get_tree().root.find_child("Skilltree", true, false)
	if tree == null:
		return
	var skill_nodes: Node = tree.get_node("MarginContainer/ClipContainer/TreeCanvas/SkillNodes")
	for child in skill_nodes.get_children():
		if child is UpgradeNode:
			var node := child as UpgradeNode
			node.is_unlocked = is_skill_node_unlocked(node.name)
			node.refresh_visual()
