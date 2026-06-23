extends State

class_name SpinningState

@export var player: CharacterBody2D
@export var animation_player: AnimationPlayer
@export var spin_duration: float = 1.2
@export var spin_speed_multiplier: float = 1.5
@export var spin_cooldown_time: float = 2.0
@export var movement_acceleration: float = 400.0
@export var movement_deceleration: float = 600.0

var _is_spinning: bool = false
var _spin_time_left: float = 0.0
var _cooldown_until_msec: int = 0


func enter() -> void:
	if not player or not player.get_can_move():
		transitioned.emit(self, "IdleState")
		return

	if _is_on_cooldown():
		_transition_to_movement_state()
		return

	_is_spinning = true
	_spin_time_left = spin_duration

	if animation_player and animation_player.has_animation(&"spin"):
		var anim_length := animation_player.get_animation(&"spin").length
		animation_player.speed_scale = anim_length / spin_duration if spin_duration > 0.0 else 1.0
		animation_player.play(&"spin")


func update(delta: float) -> void:
	if not _is_spinning:
		return

	_spin_time_left -= delta
	if _spin_time_left <= 0.0:
		_is_spinning = false
		_end_spin()
		_transition_to_movement_state()


func physics_update(delta: float) -> void:
	if not player or not _is_spinning:
		return

	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction != Vector2.ZERO:
		var target_speed: Vector2 = direction * player.speed * spin_speed_multiplier
		player.velocity = player.velocity.move_toward(target_speed, movement_acceleration * delta)
	else:
		player.velocity = player.velocity.move_toward(Vector2.ZERO, movement_deceleration * delta)

	player.move_and_slide()


func _end_spin() -> void:
	_is_spinning = false
	_spin_time_left = 0.0
	if animation_player:
		animation_player.speed_scale = 1.0
		if animation_player.has_animation(&"RESET"):
			animation_player.play(&"RESET")
	_cooldown_until_msec = Time.get_ticks_msec() + int(spin_cooldown_time * 1000.0)


func _is_on_cooldown() -> bool:
	return Time.get_ticks_msec() < _cooldown_until_msec


func _transition_to_movement_state() -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction == Vector2.ZERO:
		transitioned.emit(self, "IdleState")
	else:
		transitioned.emit(self, "MovingState")
