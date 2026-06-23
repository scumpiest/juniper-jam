extends Panel

@onready var _close_button: Button = $CloseButton
@onready var _skill_nodes: Control = $MarginContainer/ClipContainer/TreeCanvas/SkillNodes


func _ready() -> void:
	_close_button.pressed.connect(_on_close_pressed)
	for child in _skill_nodes.get_children():
		if child is UpgradeNode:
			child.unlocked.connect(_on_node_unlocked)


func _on_node_unlocked() -> void:
	for child in _skill_nodes.get_children():
		if child is UpgradeNode:
			child.refresh_visual()


func _on_close_pressed() -> void:
	SceneManager.go_to_main()