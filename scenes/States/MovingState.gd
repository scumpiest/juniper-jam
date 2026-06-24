extends State

class_name MovingState


@export var player: CharacterBody2D


func enter():
	pass


func physics_update(_delta: float):
	if player and player.get_can_move():
		var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
		player.velocity = direction * player.speed
		player.move_and_slide()

		if direction == Vector2.ZERO:
			transitioned.emit(self, "IdleState")


func _input(event: InputEvent) -> void:
	if player and player.get_can_move():
		if event.is_action_pressed("action") or event.is_action_pressed("spin"):
			transitioned.emit(self, "SpinningState")
