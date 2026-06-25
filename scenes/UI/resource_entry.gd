class_name ResourceEntry
extends HBoxContainer

var product: ProductResource

@onready var _icon: TextureRect = $Icon
@onready var _amount: Label = $Amount

const DIMMED_COLOR := Color(0, 0, 0, 1)


func setup(product_data: ProductResource) -> void:
	product = product_data
	_icon.texture = product_data.icon if product_data != null else null


func update_display(count: int) -> void:
	if count > 0:
		_icon.modulate = Color.WHITE
		_amount.text = str(count)
	else:
		_icon.modulate = DIMMED_COLOR
		_amount.text = ""
