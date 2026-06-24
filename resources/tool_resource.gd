class_name ToolResource
extends Resource

enum ToolType { WATER, HARVEST }

@export var tool_type: ToolType = ToolType.WATER
@export var icon: Texture2D
@export var display_name: String = ""
