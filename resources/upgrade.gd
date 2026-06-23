class_name Upgrade
extends Resource

enum Type {
	MOVE_SPEED,
	SPIN_SPEED,
	SPIN_DURATION,
	SPIN_RECHARGE,
	SPIN_RADIUS,
	MAGNET_RADIUS,
	WATER_HOLD,
	UNLOCK_CRAFTING,
	UNLOCK_BREEDING,
	PRODUCT_YIELD,
	SEED_YIELD,
	FINAL_SPIN,
}

@export var type: Type = Type.MOVE_SPEED
@export var value: float = 0.0
@export var plant: PlantResource


func apply() -> void:
	GlobalData.apply_upgrade(self)
