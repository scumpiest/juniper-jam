class_name UpgradeNode
extends PanelContainer

signal unlocked
signal unlock_failed

@export var requirement: UpgradeRequirement
@export var upgrade: Upgrade
@export var is_unlocked: bool = false

@onready var _animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	_animation_player.animation_finished.connect(_on_animation_finished)
	_apply_locked_visual()


func _gui_input(event: InputEvent) -> void:
	if is_unlocked:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		try_unlock()


func try_unlock() -> bool:
	if is_unlocked:
		return true
	if _can_unlock():
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
	if is_unlocked:
		modulate = Color.WHITE
	else:
		modulate = Color(0.7, 0.7, 0.7, 1.0)


func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == &"unlock_success":
		modulate = Color.WHITE
	elif anim_name == &"unlock_denied" and not is_unlocked:
		modulate = Color(0.7, 0.7, 0.7, 1.0)
