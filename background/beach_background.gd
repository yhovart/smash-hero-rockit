extends Node2D
## Animated pixel-art beach background with discrete wave frames.

var _time := 0.0
var _frame := -1

const FRAME_DURATION := 0.45
const TOTAL_FRAMES := 4

# Horizontal offsets per frame for each wave stripe
const WAVE1_X = [0.0, 6.0, 12.0, 6.0]
const WAVE2_X = [0.0, -5.0, -10.0, -5.0]
const WAVE3_X = [0.0, 4.0, 8.0, 4.0]

# Shore foam offsets per frame
const FOAM_Y = [0.0, -2.0, -4.0, -2.0]
const FOAM_X = [0.0, 3.0, 6.0, 3.0]

@onready var wave_line_1: Polygon2D = $WaveLine1
@onready var wave_line_2: Polygon2D = $WaveLine2
@onready var wave_line_3: Polygon2D = $WaveLine3
@onready var foam: Polygon2D = $Foam


func _process(delta: float) -> void:
	_time += delta
	var new_frame := int(_time / FRAME_DURATION) % TOTAL_FRAMES
	if new_frame != _frame:
		_frame = new_frame
		wave_line_1.position.x = WAVE1_X[_frame]
		wave_line_2.position.x = WAVE2_X[_frame]
		wave_line_3.position.x = WAVE3_X[_frame]
		foam.position.y = FOAM_Y[_frame]
		foam.position.x = FOAM_X[_frame]
