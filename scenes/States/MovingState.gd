extends State

class_name MovingState


@export var player: CharacterBody2D


func enter() -> void:
	pass


func physics_update(_delta: float) -> void:
	if player and player.get_can_move():
		var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
		player.velocity = direction * player.speed
		player.move_and_slide()

		if direction != Vector2.ZERO:
			_play_direction_anim(direction)
		else:
			transitioned.emit(self, "IdleState")


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


func _play_direction_anim(dir: Vector2) -> void:
	var sprite: AnimatedSprite2D = player.animated_sprite
	if abs(dir.x) >= abs(dir.y):
		sprite.play(&"move_right" if dir.x > 0 else &"move_left")
	else:
		sprite.play(&"move_down" if dir.y > 0 else &"move_up")
