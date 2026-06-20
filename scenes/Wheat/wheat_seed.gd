extends Area2D


func harvest() -> void:
	var ground: TileMapLayer = get_parent() as TileMapLayer
	if ground:
		ground.free_tile(self)
	GlobalData.number_of_wheat += 1
	queue_free()
