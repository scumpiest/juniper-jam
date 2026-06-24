extends State

class_name IdleState

@export var player: CharacterBody2D


func enter():
	if player:
		player.velocity = Vector2.ZERO


func physics_update(_delta: float):
	if not player:
		return

	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction != Vector2.ZERO:
		transitioned.emit(self, "MovingState")


func _input(event: InputEvent) -> void:
	if player and player.get_can_move():
		if event.is_action_pressed("action") or event.is_action_pressed("spin"):
			transitioned.emit(self, "SpinningState")
