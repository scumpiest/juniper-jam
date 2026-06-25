extends PanelContainer

@export var resource_entry_scene: PackedScene

@onready var _container: HBoxContainer = $HBoxContainer

var _entries: Array[ResourceEntry] = []


func _ready() -> void:
	_build_styles()
	_build_entries()
	GlobalData.inventory_updated.connect(_refresh_all)
	_refresh_all()


func _build_styles() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.12, 0.18, 0.85)
	style.set_corner_radius_all(4)
	style.set_border_width_all(1)
	style.border_color = Color(0.3, 0.3, 0.4, 0.6)
	style.set_content_margin_all(8)
	add_theme_stylebox_override("panel", style)


func _build_entries() -> void:
	for product: ProductResource in ProductDatabase.get_all_products():
		var entry := resource_entry_scene.instantiate() as ResourceEntry
		_container.add_child(entry)
		entry.setup(product)
		_entries.append(entry)


func _refresh_all() -> void:
	for entry: ResourceEntry in _entries:
		var count: int = GlobalData.product_counts.get(entry.product.id, 0)
		entry.update_display(count)
