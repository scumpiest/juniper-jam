extends State

class_name SpinningState
@export var player : CharacterBody2D

func enter():
	print(self.name)

func physics_update(_delta : float):
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")

	
	player.move_and_slide()
	

func _input(event: InputEvent) -> void:
	if player._can_move and event.is_action_pressed("spin"):
		player._start_spin()
	if player._can_move and event.is_action_released("spin"):
		player._stop_spin()
		transitioned.emit(self,"IdleState")
