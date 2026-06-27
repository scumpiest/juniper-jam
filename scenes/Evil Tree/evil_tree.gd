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
		LevelTransition.change_scene_to("res://scenes/Cutscenes/cutscene_2.tscn")
		queue_free()


func _on_hurt_box_area_entered(area: Area2D) -> void:
	adjust_health(1)
