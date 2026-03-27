class_name LevelParser

func parse(grid: Array) -> LevelModel:
	var model = LevelModel.new()

	for y in range(grid.size()):
		var line = grid[y]

		for x in range(line.length()):
			var symbol = line[x]

			match symbol:
				"#":
					model.tiles.append({
						"type": "wall",
						"x": x,
						"y": y
					})
				".":
					model.tiles.append({
						"type": "floor",
						"x": x,
						"y": y
					})
				"P":
					model.tiles.append({
						"type": "floor",
						"x": x,
						"y": y
					})
					model.player_spawn = Vector2(x, y)

	return model
