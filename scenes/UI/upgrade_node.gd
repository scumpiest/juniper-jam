class_name UpgradeNode
extends PanelContainer

signal unlocked
signal unlock_failed

const UNLOCKED_MODULATE := Color(0.45, 1.0, 0.45, 1.0)
const LOCKED_MODULATE := Color(1.0, 0.35, 0.35, 1.0)

@export var requirement: UpgradeRequirement
@export var upgrade: Upgrade
@export var is_unlocked: bool = false
@export var upgrade_texture : Texture2D

@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var texture_rect: TextureRect = $TextureRect


func _ready() -> void:
	_animation_player.animation_finished.connect(_on_animation_finished)
	if GlobalData.is_skill_node_unlocked(name):
		is_unlocked = true
	_apply_locked_visual()
	texture_rect.texture = upgrade_texture


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


func refresh_visual() -> void:
	_apply_locked_visual()


func _apply_locked_visual() -> void:
	modulate = UNLOCKED_MODULATE if is_unlocked else LOCKED_MODULATE


func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == &"unlock_success":
		modulate = UNLOCKED_MODULATE
	elif anim_name == &"unlock_denied" and not is_unlocked:
		modulate = LOCKED_MODULATE
