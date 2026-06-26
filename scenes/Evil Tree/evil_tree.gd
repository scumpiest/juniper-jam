extends CharacterBody2D

@export var health : int = 3

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animation_player.play("idle")


func _process(delta: float) -> void:
	die()

func adjust_health(amount):
	health -= amount
	animation_player.play("hit")
	await animation_player.animation_finished
	animation_player.play("idle")
	
	

func die():
	if health <= 0:
		queue_free()
