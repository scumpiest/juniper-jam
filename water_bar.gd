extends Control

@export var player : CharacterBody2D
@onready var progress_bar: ProgressBar = $ProgressBar

var tween : Tween

func _ready() -> void:
	player.water_adjusted.connect(_on_water_adjusted)
	progress_bar.max_value = player.max_water_amount
	progress_bar.min_value = player.min_water_amount
	progress_bar.value = player.water_amount

func _process(delta: float) -> void:
	progress_bar.value = player.water_amount

func _on_water_adjusted():
	tween_water()
	
	

func tween_water():
	reset_tween()
	
	tween.tween_property(progress_bar, "value", player.water_amount, 1.0)

func reset_tween():
	if tween:
		tween.kill()
	tween = create_tween()
