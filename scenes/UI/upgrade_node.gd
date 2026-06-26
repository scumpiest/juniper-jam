class_name UpgradeNode
extends PanelContainer

signal unlocked
signal unlock_failed

const UNLOCKED_MODULATE := Color(0.45, 1.0, 0.45, 1.0)
const LOCKED_MODULATE := Color(1.0, 0.35, 0.35, 1.0)
const RESOURCE_ENTRY_SCENE := preload("res://scenes/UI/resource_entry.tscn")

@export var requirement: UpgradeRequirement
@export var upgrade: Upgrade
@export var is_unlocked: bool = false
@export var upgrade_texture: Texture2D
@export var upgrade_description: String
@export var upgrade_title: String
@export var tooltip_min_size: Vector2 = Vector2(280, 100)

@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var texture_rect: TextureRect = $TextureRect
@onready var tool_tip: NinePatchRect = $ToolTip
@onready var title_label: Label = $ToolTip/VBoxContainer/TitleLabel
@onready var label: Label = $ToolTip/VBoxContainer/Label
@onready var _product_requirements: GridContainer = $ToolTip/VBoxContainer/ProductRequirements


func _ready() -> void:
	tooltip_text = ""
	_animation_player.animation_finished.connect(_on_animation_finished)
	if GlobalData.is_skill_node_unlocked(name):
		is_unlocked = true
	_apply_locked_visual()
	texture_rect.texture = upgrade_texture
	tool_tip.custom_minimum_size = tooltip_min_size
	_update_tooltip_content()
	tool_tip.visible = false
	call_deferred("_reparent_tooltip_outside_clip")


func _reparent_tooltip_outside_clip() -> void:
	var node: Node = get_parent()
	while node != null:
		if node is Control and (node as Control).clip_contents:
			var target: Node = node.get_parent()
			if target != null and tool_tip.get_parent() != target:
				tool_tip.reparent(target)
			return
		node = node.get_parent()


func _gui_input(event: InputEvent) -> void:
	if is_unlocked:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		try_unlock()


func try_unlock() -> bool:
	if is_unlocked or GlobalData.is_skill_node_unlocked(name):
		is_unlocked = true
		_apply_locked_visual()
		return true
	if _can_unlock():
		if not GlobalData.unlock_skill_node(name):
			is_unlocked = true
			_apply_locked_visual()
			return true
		if requirement != null:
			requirement.consume()
		is_unlocked = true
		if upgrade != null:
			upgrade.apply()
		_animation_player.play(&"unlock_success")
		unlocked.emit()
		return true
	_animation_player.play(&"unlock_denied")
	unlock_failed.emit()
	return false


func _can_unlock() -> bool:
	if requirement == null:
		return true
	return requirement.is_met(self)


func _update_tooltip_content() -> void:
	title_label.text = upgrade_title
	label.text = upgrade_description
	var product_requirements: Array[ProductRequirement] = []
	if requirement != null:
		product_requirements = requirement.get_product_requirements()

	for child in _product_requirements.get_children():
		child.queue_free()

	for entry: ProductRequirement in product_requirements:
		var row: ResourceEntry = RESOURCE_ENTRY_SCENE.instantiate()
		_product_requirements.add_child(row)
		row.setup(entry.product)
		row.show_required(entry.amount)


func refresh_visual() -> void:
	_apply_locked_visual()


func _apply_locked_visual() -> void:
	modulate = UNLOCKED_MODULATE if is_unlocked else LOCKED_MODULATE


func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == &"unlock_success":
		modulate = UNLOCKED_MODULATE
	elif anim_name == &"unlock_denied" and not is_unlocked:
		modulate = LOCKED_MODULATE


func _on_mouse_entered() -> void:
	_show_tooltip()


func _on_mouse_exited() -> void:
	tool_tip.visible = false


func _show_tooltip() -> void:
	await get_tree().process_frame
	if not is_inside_tree():
		return
	var tooltip_size := tool_tip.size
	if tooltip_size == Vector2.ZERO:
		tooltip_size = tool_tip.custom_minimum_size
	tool_tip.global_position = global_position + Vector2(
		size.x + 8.0,
		(size.y - tooltip_size.y) * 0.5
	)
	tool_tip.visible = true
