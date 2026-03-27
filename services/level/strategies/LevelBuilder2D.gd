extends LevelBuilder
class_name LevelBuilder2D

@export var tile_size : int = 32

func build(grid, parent, tile_size, player):
	for y in range(grid.size()):
		var line = grid[y]

		for x in range(line.length()):
			var symbol = line[x]
			var world_pos = Vector2(x, y) * tile_size

			match symbol:
				"#":
					spawn_wall(parent,world_pos)
				".":
					spawn_floor(parent,world_pos)
				"P":
					spawn_floor(parent,world_pos)
					spawn_player(parent, world_pos)
			
func spawn_wall(parent,pos):
	var body = StaticBody2D.new()
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(tile_size, tile_size)
	collision.shape = shape
	body.position = pos + Vector2(tile_size/2, tile_size/2)  # centro del tile
	body.add_child(collision)
	
	var rect = ColorRect.new()
	rect.color = Color.DARK_GRAY
	rect.size = Vector2(tile_size, tile_size)
	rect.position = -Vector2(tile_size/2, tile_size/2)  # ajustar posición relativa
	body.add_child(rect)
	
	parent.add_child(body)

func spawn_floor(parent,pos):
	var rect = ColorRect.new()
	rect.color = Color.GRAY
	rect.size = Vector2(tile_size, tile_size)
	rect.position = pos
	parent.add_child(rect)

func spawn_player(parent,pos):
	return
#
	#var collision = CollisionShape2D.new()
	#var shape = RectangleShape2D.new()
	#shape.size = Vector2(tile_size, tile_size)
	#collision.shape = shape
	#player.add_child(collision)
#
	#var rect = ColorRect.new()
	#rect.color = Color.GREEN
	#rect.size = Vector2(tile_size, tile_size)
	#rect.position = -Vector2(tile_size/2, tile_size/2)
	#player.add_child(rect)
#
	#player.position = pos + Vector2(tile_size/2, tile_size/2)
	#player.z_index = 10
#
	## Cámara
	#var camera = Camera2D.new()
	#camera.enabled = true

	# Activar zona muerta
	# camera.drag_horizontal_enabled = true
	# camera.drag_vertical_enabled = true

	# # Tamaño de la zona donde el jugador puede moverse sin mover la cámara
	# camera.drag_left_margin = 0.2
	# camera.drag_right_margin = 0.2
	# camera.drag_top_margin = 0.2
	# camera.drag_bottom_margin = 0.2

	# camera.position_smoothing_enabled = true
	# camera.position_smoothing_speed = 5

	# player.add_child(camera)

	# parent.add_child(player)
	# return player
