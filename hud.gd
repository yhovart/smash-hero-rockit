extends CanvasLayer

const MAX_HEARTS = 10
const HEARTS_PER_ROW = 5
const HEART_ICON_SIZE = 18.0

var health_points := [MAX_HEARTS, MAX_HEARTS, MAX_HEARTS, MAX_HEARTS]
var _active_count := 2

@onready var hit_containers: Array[HBoxContainer] = [$P1Shields, $P2Shields, $P3Shields, $P4Shields]
@onready var stock_containers: Array[HBoxContainer] = [$P1Stocks, $P2Stocks, $P3Stocks, $P4Stocks]
@onready var legend_bg: ColorRect = $LegendBG


func _ready() -> void:
	for i in 4:
		set_player_stocks(i, MAX_HEARTS)
	legend_bg.visible = false
	configure_for_players(2)


func configure_for_players(count: int) -> void:
	_active_count = count
	for i in 4:
		hit_containers[i].visible = i < count
		stock_containers[i].visible = i < count

	# Reposition HUD containers based on player count
	match count:
		2:
			_position_container(hit_containers[0], 16, 12, 140, 42)
			_position_container(stock_containers[0], 16, 46, 140, 70)
			_position_container(hit_containers[1], 1012, 12, 1136, 42)
			_position_container(stock_containers[1], 1012, 46, 1136, 70)
			hit_containers[1].alignment = BoxContainer.ALIGNMENT_END
			stock_containers[1].alignment = BoxContainer.ALIGNMENT_END
		3:
			_position_container(hit_containers[0], 16, 12, 140, 42)
			_position_container(stock_containers[0], 16, 46, 140, 70)
			_position_container(hit_containers[1], 500, 12, 652, 42)
			_position_container(stock_containers[1], 500, 46, 652, 70)
			_position_container(hit_containers[2], 1012, 12, 1136, 42)
			_position_container(stock_containers[2], 1012, 46, 1136, 70)
			hit_containers[1].alignment = BoxContainer.ALIGNMENT_CENTER
			stock_containers[1].alignment = BoxContainer.ALIGNMENT_CENTER
			hit_containers[2].alignment = BoxContainer.ALIGNMENT_END
			stock_containers[2].alignment = BoxContainer.ALIGNMENT_END
		4:
			_position_container(hit_containers[0], 16, 12, 140, 42)
			_position_container(stock_containers[0], 16, 46, 140, 70)
			_position_container(hit_containers[1], 350, 12, 490, 42)
			_position_container(stock_containers[1], 350, 46, 490, 70)
			_position_container(hit_containers[2], 664, 12, 804, 42)
			_position_container(stock_containers[2], 664, 46, 804, 70)
			_position_container(hit_containers[3], 1012, 12, 1136, 42)
			_position_container(stock_containers[3], 1012, 46, 1136, 70)
			hit_containers[1].alignment = BoxContainer.ALIGNMENT_CENTER
			stock_containers[1].alignment = BoxContainer.ALIGNMENT_CENTER
			hit_containers[2].alignment = BoxContainer.ALIGNMENT_CENTER
			stock_containers[2].alignment = BoxContainer.ALIGNMENT_CENTER
			hit_containers[3].alignment = BoxContainer.ALIGNMENT_END
			stock_containers[3].alignment = BoxContainer.ALIGNMENT_END


func _position_container(c: Control, left: float, top: float, right: float, bottom: float) -> void:
	c.offset_left = left
	c.offset_top = top
	c.offset_right = right
	c.offset_bottom = bottom


# ─── Generic methods ───────────────────────────────────────────────────────────

func set_player_hits(_player_index: int, _hit_count: int) -> void:
	return


func set_player_stocks(player_index: int, stocks: int) -> void:
	if player_index < 0 or player_index >= 4:
		return
	var hp := clampi(stocks, 0, MAX_HEARTS)
	health_points[player_index] = hp
	if not is_inside_tree():
		return
	var top := mini(hp, HEARTS_PER_ROW)
	var bottom := maxi(hp - HEARTS_PER_ROW, 0)
	_rebuild_heart_icons(hit_containers[player_index], top)
	_rebuild_heart_icons(stock_containers[player_index], bottom)


func set_player_face(_player_index: int, _texture: Texture2D) -> void:
	return


# ─── Backward-compatible signal methods (used by scene connections) ────────────

func set_p1_hits(h: int) -> void: set_player_hits(0, h)
func set_p2_hits(h: int) -> void: set_player_hits(1, h)
func set_p3_hits(h: int) -> void: set_player_hits(2, h)
func set_p4_hits(h: int) -> void: set_player_hits(3, h)
func set_p1_stocks(s: int) -> void: set_player_stocks(0, s)
func set_p2_stocks(s: int) -> void: set_player_stocks(1, s)
func set_p3_stocks(s: int) -> void: set_player_stocks(2, s)
func set_p4_stocks(s: int) -> void: set_player_stocks(3, s)
func set_p1_face(t: Texture2D) -> void: set_player_face(0, t)
func set_p2_face(t: Texture2D) -> void: set_player_face(1, t)
func set_p3_face(t: Texture2D) -> void: set_player_face(2, t)
func set_p4_face(t: Texture2D) -> void: set_player_face(3, t)


# ─── Icon builders ─────────────────────────────────────────────────────────────

func _rebuild_heart_icons(container: HBoxContainer, count: int) -> void:
	for child in container.get_children():
		child.queue_free()
	for i in count:
		var heart := HeartIcon.new()
		heart.custom_minimum_size = Vector2(HEART_ICON_SIZE, HEART_ICON_SIZE)
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
