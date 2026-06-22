extends State
class_name HarvestState

@export var player : CharacterBody2D
@export var animation_player : AnimationPlayer


func enter():
	print(self.name)
	
	
	#if animation_player:
	#	animation_player.play("harvest")
	#	await animation_player.animation_finished

func update(delta : float):
	player._try_harvest()
	transitioned.emit(self, "IdleState")
	
