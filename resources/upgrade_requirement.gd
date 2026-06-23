class_name UpgradeRequirement
extends Resource

@export var required_nodes: Array[StringName] = []
@export var product: ProductResource
@export var product_amount: int = 0


func is_met(node: UpgradeNode) -> bool:
	if not _are_nodes_unlocked(node):
		return false
	if product != null and product_amount > 0:
		if GlobalData.product_counts.get(product.id, 0) < product_amount:
			return false
	return true


func consume() -> void:
	if product != null and product_amount > 0:
		var current: int = GlobalData.product_counts.get(product.id, 0) - product_amount
		GlobalData.product_counts[product.id] = current
	GlobalData.inventory_updated.emit()


func _are_nodes_unlocked(node: UpgradeNode) -> bool:
	if required_nodes.is_empty():
		return true
	var skill_nodes := node.get_parent()
	if skill_nodes == null:
		return false
	for node_name: StringName in required_nodes:
		var prereq: UpgradeNode = skill_nodes.get_node_or_null(String(node_name)) as UpgradeNode
		if prereq == null or not prereq.is_unlocked:
			return false
	return true
