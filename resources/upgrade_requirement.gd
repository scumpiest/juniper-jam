class_name UpgradeRequirement
extends Resource

enum NodeRequirementMode { AND, OR }

@export var required_nodes: Array[StringName] = []
@export var required_nodes_mode: NodeRequirementMode = NodeRequirementMode.AND
@export var products: Array[ProductRequirement] = []


func is_met(node: UpgradeNode) -> bool:
	if not _are_nodes_unlocked(node):
		return false
	for entry: ProductRequirement in products:
		if entry == null or entry.product == null or entry.amount <= 0:
			continue
		if GlobalData.product_counts.get(entry.product.id, 0) < entry.amount:
			return false
	return true


func get_description(node: UpgradeNode) -> String:
	var parts: PackedStringArray = []
	var node_text := get_node_requirements_text(node)
	if node_text != "":
		parts.append(node_text)
	for entry: ProductRequirement in get_product_requirements():
		parts.append("%dx %s" % [entry.amount, entry.product.product_name])
	return ", ".join(parts) if not parts.is_empty() else "None"


func get_node_requirements_text(node: UpgradeNode) -> String:
	var parts: PackedStringArray = []
	for node_name: StringName in required_nodes:
		var prereq := _get_prereq_node(node, node_name)
		if prereq != null and prereq.upgrade_title != "":
			parts.append(prereq.upgrade_title)
		else:
			parts.append(String(node_name))
	if parts.is_empty():
		return ""
	var separator := " and " if required_nodes_mode == NodeRequirementMode.AND else " or "
	return separator.join(parts)


func get_product_requirements() -> Array[ProductRequirement]:
	var result: Array[ProductRequirement] = []
	for entry: ProductRequirement in products:
		if entry == null or entry.product == null or entry.amount <= 0:
			continue
		result.append(entry)
	return result


func consume() -> void:
	for entry: ProductRequirement in products:
		if entry == null or entry.product == null or entry.amount <= 0:
			continue
		var current: int = GlobalData.product_counts.get(entry.product.id, 0) - entry.amount
		GlobalData.product_counts[entry.product.id] = current
	GlobalData.inventory_updated.emit()


func _are_nodes_unlocked(node: UpgradeNode) -> bool:
	if required_nodes.is_empty():
		return true
	if required_nodes_mode == NodeRequirementMode.OR:
		for node_name: StringName in required_nodes:
			var prereq := _get_prereq_node(node, node_name)
			if prereq != null and prereq.is_unlocked:
				return true
		return false
	for node_name: StringName in required_nodes:
		var prereq := _get_prereq_node(node, node_name)
		if prereq == null or not prereq.is_unlocked:
			return false
	return true


func _get_prereq_node(node: UpgradeNode, node_name: StringName) -> UpgradeNode:
	var skill_nodes := node.get_parent()
	if skill_nodes == null:
		return null
	return skill_nodes.get_node_or_null(String(node_name)) as UpgradeNode
