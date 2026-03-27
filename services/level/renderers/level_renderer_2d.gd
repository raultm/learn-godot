class_name LevelRenderer2D

func render(model: LevelModel, parent: Node, tile_size: int) -> CharacterBody2D:
	var player : CharacterBody2D = null

	for tile in model.tiles:
		var world_pos = to_world(Vector2i(tile["x"], tile["y"]), tile_size)

		match tile["type"]:
			"wall":
				spawn_wall(parent, world_pos, tile_size)
			"floor":
				spawn_floor(parent, world_pos, tile_size)

	if model.player_spawn != null:
		var world_pos = to_world(model.player_spawn, tile_size)
		player = spawn_player(parent, world_pos, tile_size)

	return player



func to_world(grid_pos: Vector2i, tile_size: int) -> Vector2:
	return Vector2(grid_pos) * tile_size

func spawn_wall(parent, pos, tile_size):
	var body = StaticBody2D.new()

	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(tile_size, tile_size)
	collision.shape = shape

	body.position = pos + Vector2(tile_size/2, tile_size/2)
	body.add_child(collision)

	var rect = ColorRect.new()
	rect.color = Color.DARK_GRAY
	rect.size = Vector2(tile_size, tile_size)
	rect.position = -Vector2(tile_size/2, tile_size/2)

	body.add_child(rect)
	parent.add_child(body)

func spawn_floor(parent, pos, tile_size):
	var rect = ColorRect.new()
	rect.color = Color.GRAY
	rect.size = Vector2(tile_size, tile_size)
	rect.position = pos
	parent.add_child(rect)

func spawn_player(parent, pos, tile_size) -> CharacterBody2D:
	var player = CharacterBody2D.new()

	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(tile_size, tile_size)
	collision.shape = shape
	player.add_child(collision)

	var rect = ColorRect.new()
	rect.color = Color.GREEN
	rect.size = Vector2(tile_size, tile_size)
	rect.position = -Vector2(tile_size/2, tile_size/2)
	player.add_child(rect)

	player.position = pos + Vector2(tile_size/2, tile_size/2)
	player.z_index = 10

	parent.add_child(player)
	return player
