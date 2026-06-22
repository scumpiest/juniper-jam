extends State
class_name IdleState

@export var player : CharacterBody2D 
#@export var animation_player : AnimationPlayer

func enter():
	print(self.name)
	if player:
		player.velocity = Vector2.ZERO
		
		#if animation_player != null:
			#animation_player.play("idle")
func physics_update(delta : float):
	if not player:
		return
	
	if player:
		var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
		
		if direction != Vector2.ZERO:
			transitioned.emit(self, "MovingState")

func _input(event: InputEvent) -> void:
	if player._can_move:
		if event.is_action_pressed("harvest"):
			transitioned.emit(self, "HarvestState")
		if event.is_action_pressed("water"):
			transitioned.emit(self, "WateringState")
		if event.is_action_pressed("plant_seeds"):
			transitioned.emit(self, "PlantingState")
