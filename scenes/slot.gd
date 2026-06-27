extends PanelContainer

@export var slot_index: int = -1

@onready var _icon: TextureRect = $ItemIcon
@onready var _amount: Label = $Amount

const SELECTED_MODULATE := Color(1.15, 1.12, 0.85, 1.0)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	gui_input.connect(_on_gui_input)
	if slot_index < 0:
		return
	GlobalData.inventory_updated.connect(_update_display)
	GlobalData.slot_selection_changed.connect(_on_slot_selection_changed)
	_update_display()
	_on_slot_selection_changed(GlobalData.selected_slot_index)


func _on_gui_input(event: InputEvent) -> void:
	if slot_index < 0:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		GlobalData.select_slot(slot_index)
		accept_event()


func _on_slot_selection_changed(index: int) -> void:
	if slot_index < 0:
		return
	modulate = SELECTED_MODULATE if slot_index == index else Color.WHITE


func _update_display() -> void:
	if slot_index < 0 or slot_index >= GlobalData.hotbar_slots.size():
		return

	var item: Resource = GlobalData.hotbar_slots[slot_index]
	if item == null:
		_icon.texture = null
		_amount.text = ""
		return

	if item is ToolResource:
		var tool := item as ToolResource
		_icon.texture = tool.icon
		_amount.text = tool.display_name if tool.icon == null else ""
	elif item is ProductResource:
		var product := item as ProductResource
		_icon.texture = product.icon
		_set_amount(GlobalData.product_counts.get(product.id, 0))
	elif item is SeedResource:
		var seed_item := item as SeedResource
		_icon.texture = seed_item.icon
		_set_amount(GlobalData.seed_counts.get(seed_item.id, 0))


func _set_amount(count: int) -> void:
	_amount.text = str(count) if count > 1 else ""
