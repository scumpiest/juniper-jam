extends State
class_name PlantingState

@export var animation_player : AnimationPlayer

func enter():
	print(self.name)
	#if animation_player:
	#	animation_player.play("plant")
	#	await animation_player.animation_finished
	
func update(_delta : float):
	transitioned.emit(self, "IdleState")
