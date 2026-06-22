extends PanelContainer

@export var slot_index: int = -1

@onready var _icon: TextureRect = $TextureRect
@onready var _amount: Label = $Amount


func _ready() -> void:
	if slot_index < 0:
		return
	GlobalData.inventory_updated.connect(_update_display)
	_update_display()


func _update_display() -> void:
	if slot_index < 0 or slot_index >= GlobalData.hotbar_slots.size():
		return

	var item: Resource = GlobalData.hotbar_slots[slot_index]
	if item == null:
		_icon.texture = null
		_amount.text = ""
		return

	if item is ProductResource:
		var product := item as ProductResource
		_icon.texture = product.icon
		_set_amount(GlobalData.product_counts.get(product.id, 0))
	elif item is SeedResource:
		var seed_item := item as SeedResource
		_icon.texture = seed_item.icon
		_set_amount(GlobalData.seed_counts.get(seed_item.id, 0))


func _set_amount(count: int) -> void:
	_amount.text = str(count) if count > 1 else ""
