class_name BuildLevel

var parser
var renderer

func _init(parser, renderer):
	self.parser = parser
	self.renderer = renderer

func execute(grid: Array, parent: Node, tile_size: int):
	var model = parser.parse(grid)
	return renderer.render(model, parent, tile_size)
