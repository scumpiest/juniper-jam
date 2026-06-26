extends State

class_name SpinningState

enum ActionType { HARVEST, WATER, PLANT }

@export var player: CharacterBody2D
@export var action_type: ActionType = ActionType.HARVEST
@export var action_particles: CPUParticles2D
@export var spin_duration: float = 5.0
@export var spin_speed_multiplier: float = 1.5
@export var spin_cooldown_time: float = 2.0
@export var movement_acceleration: float = 400.0
@export var movement_deceleration: float = 600.0
@export var harvest_interval: float = 0.3

var _is_spinning: bool = false
var _spin_time_left: float = 0.0
var _cooldown_until_msec: int = 0
var _harvest_timer: float = 0.0


func enter() -> void:
	if not player or not player.get_can_move():
		transitioned.emit(self, "IdleState")
		return

	if _is_on_cooldown():
		_transition_to_movement_state()
		return

	_is_spinning = true
	_spin_time_left = _get_spin_duration()
	_harvest_timer = 0.0
	_play_spin_start()


func exit() -> void:
	if _is_spinning:
		_end_spin()


func update(delta: float) -> void:
	if not _is_spinning:
		return

	if not _is_spin_input_held():
		_end_spin_and_transition()
		return

	if _is_resource_depleted(delta):
		_end_spin_and_transition()


func _is_spin_input_held() -> bool:
	return Input.is_action_pressed("spin") or Input.is_action_pressed("action")


func _is_resource_depleted(delta: float) -> bool:
	match action_type:
		ActionType.WATER:
			return player.water_amount <= player.min_water_amount
		ActionType.PLANT:
			if not _has_seeds_to_plant():
				return true
			_spin_time_left -= delta
			return _spin_time_left <= 0.0
		_:
			_spin_time_left -= delta
			return _spin_time_left <= 0.0


func _end_spin_and_transition() -> void:
	_end_spin()
	_transition_to_movement_state()




func physics_update(delta: float) -> void:
	if not player or not _is_spinning:
		return

	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction != Vector2.ZERO:
		var target_speed: Vector2 = direction * player.speed * _get_spin_speed_multiplier()
		player.velocity = player.velocity.move_toward(target_speed, movement_acceleration * delta)
	else:
		player.velocity = player.velocity.move_toward(Vector2.ZERO, movement_deceleration * delta)

	player.move_and_slide()


	_harvest_timer -= delta
	if _harvest_timer <= 0.0:
		_harvest_timer = harvest_interval
		if _perform_action() and action_particles:
			action_particles.restart()


func _perform_action() -> bool:
	match action_type:
		ActionType.HARVEST:
			return player.try_harvest() > 0
		ActionType.WATER:
			player.try_water()
			return true
		ActionType.PLANT:
			if not _has_seeds_to_plant():
				return false
			player.try_plant_seed()
			return true
	return false


func _has_seeds_to_plant() -> bool:
	var plant := GlobalData.plant_selected
	if plant == null or plant.seed_item == null:
		return false
	return GlobalData.get_seed_count(plant.seed_item) > 0


func _play_spin_start() -> void:
	var sprite: AnimatedSprite2D = player.animated_sprite
	if not sprite.animation_finished.is_connected(_on_spin_start_finished):
		sprite.animation_finished.connect(_on_spin_start_finished, CONNECT_ONE_SHOT)
	sprite.play(&"spin_start")


func _on_spin_start_finished() -> void:
	if _is_spinning and player and player.animated_sprite.animation == &"spin_start":
		player.animated_sprite.play(&"spin_loop")


func _end_spin() -> void:
	_is_spinning = false
	_spin_time_left = 0.0
	_cooldown_until_msec = Time.get_ticks_msec() + int(_get_spin_cooldown() * 1000.0)
	if player:
		var sprite: AnimatedSprite2D = player.animated_sprite
		if sprite.animation_finished.is_connected(_on_spin_start_finished):
			sprite.animation_finished.disconnect(_on_spin_start_finished)
		sprite.play(&"spin_end")


func _is_on_cooldown() -> bool:
	return Time.get_ticks_msec() < _cooldown_until_msec


func _transition_to_movement_state() -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction == Vector2.ZERO:
		transitioned.emit(self, "IdleState")
	else:
		transitioned.emit(self, "MovingState")


func _get_spin_duration() -> float:
	return GlobalData.get_spin_duration(spin_duration)


func _get_spin_cooldown() -> float:
	return GlobalData.get_spin_cooldown(spin_cooldown_time)


func _get_spin_speed_multiplier() -> float:
	return GlobalData.get_spin_speed_multiplier(spin_speed_multiplier)
