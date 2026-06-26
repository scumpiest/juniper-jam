extends Control

@export var player: CharacterBody2D
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var _sprite: AnimatedSprite2D = player.get_node("AnimatedSprite2D") as AnimatedSprite2D

const REFILL_DURATION := 0.55
const DEPLETE_DURATION := 0.30
const BAR_HEIGHT := 5.0
const BAR_MARGIN_TOP := 1.0
const BAR_WIDTH_RATIO := 0.875

var _tween: Tween
var _empty_tween: Tween
var _target_value: float
var _display_value: float
var _speed: float = 0.0
var _depleting: bool = false
var _is_animating: bool = false
var _is_empty: bool = false


func _ready() -> void:
	_setup_bar()
	_sprite.frame_changed.connect(_update_layout)
	_sprite.animation_changed.connect(_update_layout)
	player.water_adjusted.connect(_on_water_adjusted)
	GlobalData.slot_selection_changed.connect(_on_slot_selection_changed)
	_update_layout()
	_update_visibility()
	set_process(false)


func _update_layout() -> void:
	var tex := _sprite.sprite_frames.get_frame_texture(_sprite.animation, _sprite.frame)
	if tex == null:
		return

	var sprite_size := tex.get_size() * _sprite.scale
	var bar_width := sprite_size.x * BAR_WIDTH_RATIO
	var x := (sprite_size.x - bar_width) * 0.5 + _sprite.offset.x
	var y := BAR_MARGIN_TOP + _sprite.offset.y

	offset_left = x
	offset_top = y
	offset_right = x + bar_width
	offset_bottom = y + BAR_HEIGHT


func _is_water_mode_selected() -> bool:
	var item: Resource = GlobalData.get_active_slot_item()
	return item is ToolResource and (item as ToolResource).tool_type == ToolResource.ToolType.WATER


func _update_visibility() -> void:
	visible = _is_water_mode_selected()


func _on_slot_selection_changed(_index: int) -> void:
	_update_visibility()


func _setup_bar() -> void:
	progress_bar.min_value = player.min_water_amount
	progress_bar.max_value = player.max_water_amount
	progress_bar.step = player.water_step
	_target_value = _snap_to_step(player.water_amount)
	_display_value = _target_value
	_set_bar_value(_display_value)
	progress_bar.modulate = Color.WHITE
	progress_bar.scale = Vector2.ONE
	if player.water_amount <= player.min_water_amount:
		_show_empty_state()


func _process(delta: float) -> void:
	if is_equal_approx(_display_value, _target_value):
		_stop_motion()
		return

	_display_value = move_toward(_display_value, _target_value, _speed * delta)
	_set_bar_value(_display_value)


func _on_water_adjusted() -> void:
	var new_target := _snap_to_step(float(player.water_amount))
	if is_equal_approx(new_target, _target_value):
		return

	var direction_changed := _is_animating and (new_target < _display_value) != _depleting
	_target_value = new_target
	_update_speed()

	if player.water_amount <= player.min_water_amount:
		_show_empty_state()
	elif _is_empty:
		_clear_empty_state()

	if not _is_animating:
		_begin_motion_fx()
	elif direction_changed:
		_apply_motion_fx()

	set_process(true)


func _update_speed() -> void:
	var distance := _target_value - _display_value
	if is_zero_approx(distance):
		_speed = 0.0
		return

	_depleting = distance < 0.0
	if _depleting:
		var step := maxf(progress_bar.step, 1.0)
		_speed = step / DEPLETE_DURATION
	else:
		_speed = absf(distance) / REFILL_DURATION


func _snap_to_step(amount: float) -> float:
	var step := progress_bar.step
	if step <= 0.0:
		return amount
	return snappedf(amount, step)


func _set_bar_value(amount: float) -> void:
	progress_bar.value = _snap_to_step(amount)


func _begin_motion_fx() -> void:
	_is_animating = true
	_kill_tween()
	_apply_motion_fx()


func _apply_motion_fx() -> void:
	if _depleting:
		progress_bar.modulate = Color(1.2, 0.88, 0.88)
		progress_bar.scale = Vector2(0.98, 0.94)
	else:
		progress_bar.modulate = Color(0.8, 1.15, 1.3)
		progress_bar.scale = Vector2(1.03, 1.06)


func _stop_motion() -> void:
	if not _is_animating:
		set_process(false)
		return

	_is_animating = false
	set_process(false)
	_kill_tween()

	if _is_empty:
		return

	_tween = create_tween()
	_tween.set_parallel(true)
	_tween.tween_property(progress_bar, "modulate", Color.WHITE, 0.15)
	_tween.tween_property(progress_bar, "scale", Vector2.ONE, 0.15) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _show_empty_state() -> void:
	if _is_empty:
		return
	_is_empty = true
	_kill_tween()
	if _empty_tween:
		_empty_tween.kill()
	progress_bar.scale = Vector2.ONE
	_empty_tween = create_tween().set_loops()
	_empty_tween.tween_property(progress_bar, "modulate", Color(0.45, 0.45, 0.55, 0.55), 0.5)
	_empty_tween.tween_property(progress_bar, "modulate", Color(0.65, 0.65, 0.75, 1.0), 0.5)


func _clear_empty_state() -> void:
	if not _is_empty:
		return
	_is_empty = false
	if _empty_tween:
		_empty_tween.kill()
	_empty_tween = null
	progress_bar.modulate = Color.WHITE


func _kill_tween() -> void:
	if _tween:
		_tween.kill()
	_tween = null
