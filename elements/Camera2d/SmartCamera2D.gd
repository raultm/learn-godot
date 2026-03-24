extends Camera2D

@export var look_ahead_distance : float = 80
@export var look_ahead_speed : float = 4
@export var smoothing_speed : float = 5

var player : CharacterBody2D
var look_offset := Vector2.ZERO

func _ready():
	position_smoothing_enabled = true
	position_smoothing_speed = smoothing_speed

	drag_horizontal_enabled = true
	drag_vertical_enabled = true

	drag_left_margin = 0.2
	drag_right_margin = 0.2
	drag_top_margin = 0.2
	drag_bottom_margin = 0.2


func _process(delta):
	if player == null:
		return

	var dir = player.velocity.normalized()

	if dir.length() > 0:
		var target = dir * look_ahead_distance
		look_offset = look_offset.lerp(target, delta * look_ahead_speed)
	else:
		look_offset = look_offset.lerp(Vector2.ZERO, delta * look_ahead_speed)

	offset = look_offset
