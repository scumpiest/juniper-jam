extends PanelContainer

@export var slot_index: int = -1

@onready var _icon: TextureRect = $ItemIcon
@onready var _amount: Label = $Amount
@onready var _background: TextureRect = $SlotBackground

var _normal_style: StyleBoxEmpty
var _selected_style: StyleBoxFlat


func _ready() -> void:
	_normal_style = StyleBoxEmpty.new()
	_selected_style = StyleBoxFlat.new()
	_selected_style.bg_color = Color(1.0, 0.78, 0.12, 0.45)
	_selected_style.border_color = Color(1.0, 0.92, 0.35, 1.0)
	_selected_style.set_border_width_all(3)
	_selected_style.set_corner_radius_all(4)
	_selected_style.set_expand_margin_all(2)
	add_theme_stylebox_override("panel", _normal_style)

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
	var selected := slot_index == index
	if selected:
		add_theme_stylebox_override("panel", _selected_style)
		_background.modulate = Color(1.25, 1.15, 0.85)
	else:
		add_theme_stylebox_override("panel", _normal_style)
		_background.modulate = Color.WHITE


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
