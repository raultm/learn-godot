extends LevelRenderer2D
class_name LevelRenderer2DIsometric

func to_world(grid_pos: Vector2i, tile_size: int) -> Vector2:
	# Coordenadas isométricas clásicas
	var x = (grid_pos.x - grid_pos.y) * tile_size / 2
	var y = (grid_pos.x + grid_pos.y) * tile_size / 4
	return Vector2(x, y)