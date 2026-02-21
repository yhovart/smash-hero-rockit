extends Node2D
## Animated lava cavern background for Pitfall arena.

var _time := 0.0
var _frame := -1

const FRAME_DURATION := 0.5
const TOTAL_FRAMES := 4

# Lava surface glow flicker offsets
const LAVA_Y = [0.0, -2.0, -3.0, -1.0]
const GLOW_ALPHA = [0.35, 0.45, 0.55, 0.42]

@onready var lava_surface: Polygon2D = $LavaSurface
@onready var glow: ColorRect = $Glow


func _process(delta: float) -> void:
	_time += delta
	var new_frame := int(_time / FRAME_DURATION) % TOTAL_FRAMES
	if new_frame != _frame:
		_frame = new_frame
		lava_surface.position.y = LAVA_Y[_frame]
		var c := glow.color
		glow.color = Color(c.r, c.g, c.b, GLOW_ALPHA[_frame])
