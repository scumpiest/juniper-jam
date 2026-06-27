extends Area2D

const RIVER_COLLISION_LAYER := 64

@onready var _area_shape: CollisionPolygon2D = $CollisionPolygon2D

var _river_blocker: StaticBody2D


func _ready() -> void:
	_setup_river_blocker()
	GlobalData.upgrades_changed.connect(_update_river_blocking)
	_update_river_blocking()


func _setup_river_blocker() -> void:
	_river_blocker = StaticBody2D.new()
	_river_blocker.name = &"RiverBlocker"
	_river_blocker.collision_layer = RIVER_COLLISION_LAYER
	_river_blocker.collision_mask = 0
	add_child(_river_blocker)

	var blocker_shape := CollisionPolygon2D.new()
	blocker_shape.polygon = _area_shape.polygon
	blocker_shape.position = _area_shape.position
	_river_blocker.add_child(blocker_shape)


func _update_river_blocking() -> void:
	var passable := GlobalData.can_move_over_water()
	_river_blocker.collision_layer = 0 if passable else RIVER_COLLISION_LAYER
