extends State

class_name SpinningState
@export var player: CharacterBody2D
@export var spin_acceleration: float = 400.0
@export var max_spin_speed: float = 1000.0
@export var spin_speed_multiplier: float = 1.5
@export var spin_duration: float = 1.2
@export var spin_cooldown_time: float = 2.0
@export var rotation_reset_speed: float = 720.0
@export var movement_acceleration: float = 400.0
@export var movement_deceleration: float = 600.0

var _spin_speed: float = 0.0
var _spin_time_left: float = 0.0
var _is_spinning: bool = false
var _is_resetting_rotation: bool = false
var _cooldown_until_msec: int = 0


func enter():
	print(self.name)
	if not player or not player.get_can_move():
		transitioned.emit(self, "IdleState")
		return

	if _is_on_cooldown():
		print("Spin blocked — %.1fs cooldown remaining" % _get_cooldown_remaining_sec())
		_transition_to_movement_state()
		return

	_is_spinning = true
	_is_resetting_rotation = false
	_spin_speed = 0.0
	_spin_time_left = spin_duration


func physics_update(delta: float):
	if not player:
		return

	if _is_resetting_rotation:
		_update_rotation_reset(delta)
		player.move_and_slide()
		return

	if _is_spinning:
		_update_spin(delta)
		player.move_and_slide()
		return

	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	player.velocity = direction * player.speed

	player.move_and_slide()


func _update_spin(delta: float) -> void:
	_spin_time_left -= delta
	if _spin_time_left <= 0.0:
		_end_spin()
		return

	_spin_speed = min(_spin_speed + spin_acceleration * delta, max_spin_speed)
	player.rotation_degrees += _spin_speed * delta

	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction != Vector2.ZERO:
		var target_speed: Vector2 = direction * player.speed * spin_speed_multiplier
		player.velocity = player.velocity.move_toward(target_speed, movement_acceleration * delta)
	else:
		player.velocity = player.velocity.move_toward(Vector2.ZERO, movement_deceleration * delta)


func _update_rotation_reset(delta: float) -> void:
	var step := rotation_reset_speed * delta
	if absf(player.rotation_degrees) <= step:
		player.rotation_degrees = 0.0
		_is_resetting_rotation = false
		_transition_to_movement_state()
		return

	player.rotation_degrees = move_toward(player.rotation_degrees, 0.0, step)
	player.velocity = player.velocity.move_toward(Vector2.ZERO, movement_deceleration * delta)


func _end_spin() -> void:
	_is_spinning = false
	_spin_speed = 0.0
	_cooldown_until_msec = Time.get_ticks_msec() + int(spin_cooldown_time * 1000.0)
	print("Spin cooldown started — %.1fs" % spin_cooldown_time)
	_start_rotation_reset()


func _is_on_cooldown() -> bool:
	return Time.get_ticks_msec() < _cooldown_until_msec


func _get_cooldown_remaining_sec() -> float:
	if not _is_on_cooldown():
		return 0.0
	return float(_cooldown_until_msec - Time.get_ticks_msec()) / 1000.0


func _start_rotation_reset() -> void:
	if absf(player.rotation_degrees) < 0.5:
		player.rotation_degrees = 0.0
		_transition_to_movement_state()
		return

	_is_resetting_rotation = true


func _transition_to_movement_state() -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction == Vector2.ZERO:
		transitioned.emit(self, "IdleState")
	else:
		transitioned.emit(self, "MovingState")


func _input(event: InputEvent) -> void:
	if not player or not player.get_can_move():
		return

	if event.is_action_released("spin") and _is_spinning:
		_end_spin()
