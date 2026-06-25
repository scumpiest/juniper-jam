extends CharacterBody2D

@export var health : int = 3



func _process(delta: float) -> void:
	die()

func adjust_health(amount):
	health -= amount
	

func die():
	if health <= 0:
		queue_free()
