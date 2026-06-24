extends State

class_name IdleState

@export var player: CharacterBody2D


func enter():
	if player:
		player.velocity = Vector2.ZERO
		player.animated_sprite.play(&"idle")


func physics_update(_delta: float):
	if not player:
		return

	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction != Vector2.ZERO:
		transitioned.emit(self, "MovingState")


func _input(event: InputEvent) -> void:
	if not player or not player.get_can_move():
		return
	if event.is_action_pressed("spin"):
		transitioned.emit(self, "SpinningState")
	elif event.is_action_pressed("action"):
		_handle_action()


func _handle_action() -> void:
	var item: Resource = GlobalData.get_active_slot_item()
	if item is ToolResource:
		match (item as ToolResource).tool_type:
			ToolResource.ToolType.HARVEST:
				transitioned.emit(self, "SpinningState")
			ToolResource.ToolType.WATER:
				transitioned.emit(self, "WateringSpinState")
	elif item is SeedResource:
		transitioned.emit(self, "PlantingSpinState")
