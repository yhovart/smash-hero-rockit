extends CanvasLayer

const MAX_HITS = 3
const HIT_ICON_SIZE = 28.0
const TROPHY_ICON_SIZE = 22.0

var p1_hits := 0
var p2_hits := 0
var p1_face_texture: Texture2D = null
var p2_face_texture: Texture2D = null

@onready var p1_hits_container: HBoxContainer = $P1Shields
@onready var p2_hits_container: HBoxContainer = $P2Shields
@onready var p1_stocks_container: HBoxContainer = $P1Stocks
@onready var p2_stocks_container: HBoxContainer = $P2Stocks

func _ready() -> void:
	_rebuild_hit_icons(p1_hits_container, MAX_HITS, p1_face_texture)
	_rebuild_hit_icons(p2_hits_container, MAX_HITS, p2_face_texture)

func set_p1_face(texture: Texture2D) -> void:
	p1_face_texture = texture
	if is_inside_tree() and p1_hits_container != null:
		_rebuild_hit_icons(p1_hits_container, MAX_HITS - p1_hits, p1_face_texture)

func set_p2_face(texture: Texture2D) -> void:
	p2_face_texture = texture
	if is_inside_tree() and p2_hits_container != null:
		_rebuild_hit_icons(p2_hits_container, MAX_HITS - p2_hits, p2_face_texture)

func set_p1_hits(hits: int) -> void:
	p1_hits = hits
	if is_inside_tree() and p1_hits_container != null:
		_rebuild_hit_icons(p1_hits_container, MAX_HITS - hits, p1_face_texture)

func set_p2_hits(hits: int) -> void:
	p2_hits = hits
	if is_inside_tree() and p2_hits_container != null:
		_rebuild_hit_icons(p2_hits_container, MAX_HITS - hits, p2_face_texture)

func set_p1_stocks(stocks: int) -> void:
	if is_inside_tree() and p1_stocks_container != null:
		_rebuild_trophy_icons(p1_stocks_container, stocks)

func set_p2_stocks(stocks: int) -> void:
	if is_inside_tree() and p2_stocks_container != null:
		_rebuild_trophy_icons(p2_stocks_container, stocks)

func _rebuild_hit_icons(container: HBoxContainer, remaining: int, face_tex: Texture2D) -> void:
	for child in container.get_children():
		child.queue_free()
	for i in MAX_HITS:
		var icon := TextureRect.new()
		icon.custom_minimum_size = Vector2(HIT_ICON_SIZE, HIT_ICON_SIZE)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		if face_tex != null:
			icon.texture = face_tex
		if i >= remaining:
			icon.modulate = Color(0.25, 0.25, 0.25, 0.4)
		container.add_child(icon)

func _rebuild_trophy_icons(container: HBoxContainer, count: int) -> void:
	for child in container.get_children():
		child.queue_free()
	for i in count:
		var heart := HeartIcon.new()
		heart.custom_minimum_size = Vector2(TROPHY_ICON_SIZE, TROPHY_ICON_SIZE)
		container.add_child(heart)


class HeartIcon extends Control:
	func _draw() -> void:
		var cx := size.x / 2.0
		var cy := size.y / 2.0
		var sx := size.x * 0.48
		var sy := size.y * 0.46
		var pts := PackedVector2Array()
		var steps := 32
		for i in steps + 1:
			var t := float(i) / float(steps) * TAU
			var x := sx * (16.0 * pow(sin(t), 3)) / 16.0
			var y := -sy * (13.0 * cos(t) - 5.0 * cos(2.0 * t) - 2.0 * cos(3.0 * t) - cos(4.0 * t)) / 16.0
			pts.append(Vector2(cx + x, cy + y - size.y * 0.05))
		draw_colored_polygon(pts, Color(0.9, 0.15, 0.2, 1.0))
		draw_polyline(pts, Color(1.0, 0.4, 0.45, 0.6), 1.0)
