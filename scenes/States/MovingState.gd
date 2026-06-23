extends State
class_name MovingState

@export var player : CharacterBody2D 



func enter():
	print(self.name)

func physics_update(delta : float):
	if player and  player.get_can_move():
		var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
		player.velocity = direction * player.speed
		player.move_and_slide()
		
		if direction == Vector2.ZERO:
			transitioned.emit(self, "IdleState")

func _input(event: InputEvent) -> void:
	if player and player.get_can_move():
		if event.is_action_pressed("harvest"):
			transitioned.emit(self, "HarvestState")
		if event.is_action_pressed("water"):
			transitioned.emit(self, "WateringState")
		if event.is_action_pressed("plant_seeds"):
			transitioned.emit(self, "PlantingState")
		if event.is_action_pressed("spin"):
			transitioned.emit(self, "SpinningState")
