extends CharacterBody2D

@export var health : int = 3

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _process(delta: float) -> void:
	die()

func adjust_health(amount):
	animation_player.play("hit")
	health -= amount
	

func die():
	if health <= 0:
		queue_free()
