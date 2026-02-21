extends CanvasLayer

const MAX_HITS = 3
const SHIELD_SIZE = 20.0
const SHIELD_SPACING = 28.0
const MARGIN = 16.0

var p1_hits := 0
var p2_hits := 0

@onready var p1_container: Control = $P1Shields
@onready var p2_container: Control = $P2Shields

func _ready() -> void:
	_build_shields(p1_container, MAX_HITS)
	_build_shields(p2_container, MAX_HITS)
	_update_shields()

func set_p1_hits(hits: int) -> void:
	p1_hits = hits
	if is_inside_tree() and p1_container != null:
		_update_shields()

func set_p2_hits(hits: int) -> void:
	p2_hits = hits
	if is_inside_tree() and p2_container != null:
		_update_shields()

func _build_shields(container: Control, count: int) -> void:
	for i in count:
		var shield := ShieldIcon.new()
		shield.custom_minimum_size = Vector2(SHIELD_SIZE, SHIELD_SIZE + 4)
		container.add_child(shield)

func _update_shields() -> void:
	for i in p1_container.get_child_count():
		var shield: ShieldIcon = p1_container.get_child(i) as ShieldIcon
		shield.alive = i >= p1_hits
		shield.shield_color = Color(0.15, 0.45, 0.95, 1.0)
		shield.queue_redraw()

	for i in p2_container.get_child_count():
		var shield: ShieldIcon = p2_container.get_child(i) as ShieldIcon
		shield.alive = i >= p2_hits
		shield.shield_color = Color(0.9, 0.2, 0.15, 1.0)
		shield.queue_redraw()


class ShieldIcon extends Control:
	var alive := true
	var shield_color := Color.WHITE

	func _draw() -> void:
		var cx := size.x / 2.0
		var w := size.x * 0.45
		var top := 2.0
		var mid := size.y * 0.45
		var bot := size.y - 2.0

		var points := PackedVector2Array([
			Vector2(cx, top),
			Vector2(cx + w, top + 4),
			Vector2(cx + w, mid),
			Vector2(cx + w * 0.6, mid + (bot - mid) * 0.5),
			Vector2(cx, bot),
			Vector2(cx - w * 0.6, mid + (bot - mid) * 0.5),
			Vector2(cx - w, mid),
			Vector2(cx - w, top + 4),
		])

		if alive:
			draw_colored_polygon(points, shield_color)
			draw_polyline(points + PackedVector2Array([points[0]]), Color(1, 1, 1, 0.4), 1.5)
		else:
			draw_colored_polygon(points, Color(0.3, 0.3, 0.3, 0.4))
			draw_polyline(points + PackedVector2Array([points[0]]), Color(0.5, 0.5, 0.5, 0.3), 1.0)
			var crack_start := Vector2(cx - 3, top + 6)
			var crack_end := Vector2(cx + 2, bot - 6)
			var crack_mid := Vector2(cx + 4, (top + bot) / 2.0)
			draw_polyline(PackedVector2Array([crack_start, crack_mid, crack_end]), Color(0.6, 0.1, 0.1, 0.6), 1.5)
