extends State

class_name WateringState

@export var player : CharacterBody2D
@export var animation_player : AnimationPlayer

func enter():
	print(self.name)
	
	#if animation_player:
	#	animation_player.play("water")
	#	await animation_player.animation_finished
	
func update(delta : float):
	player.try_water()
	transitioned.emit(self, "IdleState")
	
