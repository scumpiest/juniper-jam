extends Control

@onready var item_icon: Sprite2D = $InnerBorder/ItemIcon
@onready var item_name: Label = $DetailsPanel/ItemName
@onready var item_type: Label = $DetailsPanel/ItemType
@onready var item_points: Label = $DetailsPanel/ItemPoints
@onready var details_panel: ColorRect = $DetailsPanel
@onready var item_amount: Label = $InnerBorder/ItemAmount

@export var assigned_product : ProductResource

var item = null

func _ready() -> void:
	GlobalData.inventory_updated.connect(update_slot_ui)
	update_slot_ui()

func _on_item_button_pressed() -> void:
	pass


func _on_item_button_mouse_entered() -> void:
	if item != null :
		details_panel.visible = true


func _on_item_button_mouse_exited() -> void:
	if item != null :
		details_panel.visible = false
	

func update_slot_ui():
	if assigned_product == null:
		item_icon.texture = null
		item_amount.text = ""
		return
	var current_amount = GlobalData.product_counts.get(assigned_product.id, 0)
	
	if current_amount > 0:
		item_icon.texture = assigned_product.icon
		item_amount.text = str(current_amount)
		#show
	else:
		item_icon.texture = null
		item_amount.text = ""
