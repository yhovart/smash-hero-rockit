extends Node2D

# ─── Constants ─────────────────────────────────────────────────────────────────

const PLAYER_ACTION_SETS: Array = [
	["p1_left", "p1_right", "p1_jump", "p1_attack", "p1_vapor", "p1_puddle", "p1_dash"],
	["p2_left", "p2_right", "p2_jump", "p2_attack", "p2_vapor", "p2_puddle", "p2_dash"],
	["p3_left", "p3_right", "p3_jump", "p3_attack", "p3_vapor", "p3_puddle", "p3_dash"],
	["p4_left", "p4_right", "p4_jump", "p4_attack", "p4_vapor", "p4_puddle", "p4_dash"],
]
const CHARACTER_NAMES: Array[String] = [
	"Franck",
	"Yves-Henri",
	"Joel",
	"Maite",
	"Alexia",
	"Gevrai",
	"Raphael",
	"Roxane",
	"Tommy",
	"Ash",
]
const CHARACTER_ASSET_PREFIXES: Array[String] = [
	"franck",
	"Yves-Henri",
	"Joel",
	"Maite",
	"Alexia",
	"Gevrai",
	"Raphael",
	"Roxane",
	"Tommy",
	"Ash",
]
const CHARACTER_COLORS: Array[Color] = [
	Color(0.15, 0.45, 0.95, 1.0),
	Color(0.9, 0.2, 0.15, 1.0),
	Color(0.2, 0.8, 0.35, 1.0),
	Color(0.95, 0.75, 0.2, 1.0),
	Color(0.78, 0.32, 0.92, 1.0),
	Color(0.2, 0.74, 0.82, 1.0),
	Color(0.96, 0.56, 0.22, 1.0),
	Color(0.86, 0.32, 0.54, 1.0),
	Color(0.28, 0.84, 0.58, 1.0),
	Color(0.7, 0.7, 0.75, 1.0),
]
const PLAYER_LABEL_COLORS: Array[Color] = [
	Color(0.5, 0.7, 1.0, 1.0),
	Color(1.0, 0.5, 0.45, 1.0),
	Color(0.5, 1.0, 0.6, 1.0),
	Color(1.0, 0.85, 0.4, 1.0),
]
const ARENA_NAMES: Array[String] = ["Forest", "Beach", "Volcano"]
const ARENA_BG_SCENES: Array[String] = [
	"res://background/forest_background.tscn",
	"res://background/beach_background.tscn",
	"res://background/cavern_background.tscn",
]
const ARENA_FLOOR_COLORS: Array[Color] = [
	Color(0.35, 0.23, 0.14, 1),
	Color(0.76, 0.65, 0.42, 1),
	Color(0.25, 0.12, 0.08, 1),
]
const ARENA_MOSS_COLORS: Array[Color] = [
	Color(0.2, 0.54, 0.22, 1),
	Color(0.82, 0.72, 0.48, 1),
	Color(0.55, 0.22, 0.05, 1),
]
const ARENA_PLAT_COLORS: Array[Color] = [
	Color(0.4, 0.25, 0.14, 1),
	Color(0.55, 0.42, 0.28, 1),
	Color(0.3, 0.15, 0.10, 1),
]
const ARENA_PLAT_MOSS_COLORS: Array[Color] = [
	Color(0.2, 0.56, 0.24, 1),
	Color(0.62, 0.50, 0.34, 1),
	Color(0.50, 0.20, 0.05, 1),
]
const ARENA_FLOOR_HALF_WIDTHS: Array[float] = [400.0, 350.0, 300.0]
const FLOOR_CENTER_X := 576.0
const FLOOR_Y := 600.0
const RESULT_MIN_DISPLAY := 2.0
const PLAYER_MAX_STOCKS := 10
const SFX_CHEVRE_PATH := "res://assets/sounds/chevre.mp3"
const SFX_WILHELM_PATH := "res://assets/sounds/wilhelm.mp3"
const SFX_FINISH_HIM_PATH := "res://assets/sounds/finish-him.mp3"
const SFX_VICTORY_PATH := "res://assets/sounds/victoryff.swf.mp3"
const SFX_JUMP_PATH := "res://assets/sounds/jump.mp3"
const SPAWN_Y := 500.0
const VIEWPORT_W := 1152.0
const VIEWPORT_H := 648.0
const P1_ACTIONS: Array[String] = ["p1_left", "p1_right", "p1_jump", "p1_attack", "p1_vapor", "p1_puddle", "p1_dash"]
const P2_ACTIONS: Array[String] = ["p2_left", "p2_right", "p2_jump", "p2_attack", "p2_vapor", "p2_puddle", "p2_dash"]
const P3_ACTIONS: Array[String] = ["p3_left", "p3_right", "p3_jump", "p3_attack", "p3_vapor", "p3_puddle", "p3_dash"]
const P4_ACTIONS: Array[String] = ["p4_left", "p4_right", "p4_jump", "p4_attack", "p4_vapor", "p4_puddle", "p4_dash"]
const ALL_ACTION_SETS: Array = [P1_ACTIONS, P2_ACTIONS, P3_ACTIONS, P4_ACTIONS]

const CONTROLS_2P: Array[String] = [
	"Move: A / D\nJump: W\nAttack: E\nDash: R\nVapor: Q  Fastfall: S",
	"Move: J / L\nJump: I\nAttack: O\nDash: H\nVapor: U  Fastfall: K",
]
const CONTROLS_MULTI: Array[String] = [
	"Gamepad 1 only",
	"Gamepad 2 only",
	"Move: A / D\nJump: W\nAttack: E\nDash: R\nVapor: Q  Fastfall: S",
	"Move: J / L\nJump: I\nAttack: O\nDash: H\nVapor: U  Fastfall: K",
]

# ─── Enums / State ─────────────────────────────────────────────────────────────

enum MenuPhase { PLAYER_COUNT, CHARACTER_SELECT, ARENA_SELECT, NONE }

@export var log_remote_input := true

var menu_phase: MenuPhase = MenuPhase.PLAYER_COUNT
var num_players := 2
var count_cursor := 0
var char_indices: Array[int] = [0, 1, 2, 3]
var char_locked: Array[bool] = [false, false, false, false]
var arena_cursor := 0
var is_result_active := false
var result_input_delay := 0.0
var selected_arena_index := 0
var menu_asset_lookup: Dictionary = {}
var _current_bg: Node = null
var _arena_preview_bgs: Array = [null, null, null]
var previous_stocks: Array[int] = [PLAYER_MAX_STOCKS, PLAYER_MAX_STOCKS, PLAYER_MAX_STOCKS, PLAYER_MAX_STOCKS]
var eliminated_players: Array[bool] = [false, false, false, false]
var elimination_order: Array[int] = []

var chevre_player: AudioStreamPlayer
var wilhelm_player: AudioStreamPlayer
var finish_him_player: AudioStreamPlayer
var victory_player: AudioStreamPlayer
var jump_player: AudioStreamPlayer

# ─── Scene References ──────────────────────────────────────────────────────────

@onready var all_players: Array[Node] = [$Player1, $Player2, $Player3, $Player4]
@onready var hud: CanvasLayer = $HUD
@onready var hazard_spawner: Node = $HazardSpawner
@onready var platform_1: Node2D = $Platform1
@onready var platform_2: Node2D = $Platform2
@onready var platform_3: Node2D = $Platform3
@onready var platform_1_shape: CollisionShape2D = $Platform1/CollisionShape2D
@onready var platform_2_shape: CollisionShape2D = $Platform2/CollisionShape2D
@onready var platform_3_shape: CollisionShape2D = $Platform3/CollisionShape2D
@onready var platform_1_visual: ColorRect = $Platform1/ColorRect
@onready var platform_2_visual: ColorRect = $Platform2/ColorRect
@onready var platform_3_visual: ColorRect = $Platform3/ColorRect
@onready var floor_body: StaticBody2D = $Floor
@onready var floor_shape: CollisionShape2D = $Floor/CollisionShape2D
@onready var floor_visual: ColorRect = $Floor/ColorRect
@onready var floor_moss: ColorRect = $Floor/Moss
@onready var floor_left_body: StaticBody2D = $FloorLeft
@onready var floor_left_shape: CollisionShape2D = $FloorLeft/CollisionShape2D
@onready var floor_left_visual: ColorRect = $FloorLeft/ColorRect
@onready var floor_left_moss: ColorRect = $FloorLeft/Moss
@onready var floor_right_body: StaticBody2D = $FloorRight
@onready var floor_right_shape: CollisionShape2D = $FloorRight/CollisionShape2D
@onready var floor_right_visual: ColorRect = $FloorRight/ColorRect
@onready var floor_right_moss: ColorRect = $FloorRight/Moss
@onready var platform_1_moss: ColorRect = $Platform1/Moss
@onready var platform_2_moss: ColorRect = $Platform2/Moss
@onready var platform_3_moss: ColorRect = $Platform3/Moss
@onready var bg_container: Node2D = $BackgroundContainer
@onready var _old_char_select: CanvasLayer = $CharacterSelect
@onready var end_screen: CanvasLayer = $EndScreen
@onready var end_panel: Panel = $EndScreen/Panel
@onready var end_backdrop: ColorRect = $EndScreen/Backdrop
@onready var end_title: Label = $EndScreen/Panel/Title
@onready var end_subtitle: Label = $EndScreen/Panel/SubTitle
@onready var winner_tag: Label = $EndScreen/Panel/WinnerTag
@onready var loser_tag: Label = $EndScreen/Panel/LoserTag
@onready var winner_face: TextureRect = $EndScreen/Panel/WinnerFace
@onready var loser_face: TextureRect = $EndScreen/Panel/LoserFace
@onready var end_score: Label = $EndScreen/Panel/Score
@onready var end_arena: Label = $EndScreen/Panel/Arena
@onready var end_hint: Label = $EndScreen/Panel/Hint
var _end_loser_extra_nodes: Array[Node] = []

# ─── Programmatic UI ───────────────────────────────────────────────────────────

var _count_layer: CanvasLayer
var _count_boxes: Array[ColorRect] = []
var _count_labels: Array[Label] = []

var _char_layer: CanvasLayer
var _char_title: Label
var _char_face_rects: Array[TextureRect] = []
var _char_name_labels: Array[Label] = []
var _char_status_labels: Array[Label] = []
var _char_control_labels: Array[Label] = []
var _char_hint: Label
var _char_columns: Array[Control] = []

var _arena_layer: CanvasLayer
var _arena_title: Label
var _arena_cards: Array[ColorRect] = []
var _arena_card_labels: Array[Label] = []
var _arena_card_bg_holders: Array[Node2D] = []
var _arena_card_glows: Array[ColorRect] = []
var _arena_hint: Label

# ─── Ready ─────────────────────────────────────────────────────────────────────

func _ready() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	_register_extra_actions()
	for i in 4:
		var p: Node = all_players[i]
		if p.has_signal("eliminated"):
			p.connect("eliminated", _on_player_eliminated.bind(i))
		if p.has_signal("stock_changed"):
			p.connect("stock_changed", _on_player_stock_changed.bind(i))
		if p.has_signal("got_hit"):
			p.connect("got_hit", _on_player_got_hit)
		if p.has_signal("fell_out"):
			p.connect("fell_out", _on_player_fell_out)
		if p.has_signal("jumped"):
			p.connect("jumped", _on_player_jumped)
	_setup_audio_players()
	_build_menu_asset_lookup()
	_swap_background(0)
	end_screen.visible = false
	_old_char_select.visible = false
	hud.visible = false
	_set_gameplay_enabled(false)
	_build_count_screen()
	_build_char_screen()
	_build_arena_screen()
	_show_phase(MenuPhase.PLAYER_COUNT)
	_ensure_remote_fallback_bindings()
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	_refresh_joypad_mapping()


func _process(delta: float) -> void:
	if is_result_active:
		result_input_delay = max(result_input_delay - delta, 0.0)
		_handle_result_input()
		return
	match menu_phase:
		MenuPhase.PLAYER_COUNT:
			_handle_count_input()
		MenuPhase.CHARACTER_SELECT:
			_handle_char_input()
		MenuPhase.ARENA_SELECT:
			_handle_arena_input()
		MenuPhase.NONE:
			_handle_in_fight_input()


# ─── Phase Management ──────────────────────────────────────────────────────────

func _show_phase(phase: MenuPhase) -> void:
	menu_phase = phase
	_count_layer.visible = (phase == MenuPhase.PLAYER_COUNT)
	_char_layer.visible = (phase == MenuPhase.CHARACTER_SELECT)
	_arena_layer.visible = (phase == MenuPhase.ARENA_SELECT)
	hud.visible = (phase == MenuPhase.NONE and not is_result_active)
	if phase == MenuPhase.PLAYER_COUNT:
		_restore_default_keyboard_layout()
		_update_count_ui()
	elif phase == MenuPhase.CHARACTER_SELECT:
		if num_players >= 3:
			_apply_keyboard_layout_for_player_count()
		_reset_char_select()
		_update_char_ui()
	elif phase == MenuPhase.ARENA_SELECT:
		_update_arena_ui()


# ─── Input Registration (P3/P4) ───────────────────────────────────────────────

func _register_extra_actions() -> void:
	for suffix in ["left", "right", "jump", "attack", "vapor", "puddle", "dash"]:
		for prefix in ["p3", "p4"]:
			var action_name := "%s_%s" % [prefix, suffix]
			if not InputMap.has_action(action_name):
				InputMap.add_action(action_name, 0.2)
	# P3 starts with P1's default keys (A/D/W/E/Q/S/R)
	var p1_keys := P1_DEFAULT_KEYS.values()
	var p3_actions_list := P3_ACTIONS
	for i in p3_actions_list.size():
		_bind_key_to_action(p3_actions_list[i], p1_keys[i])
	# P4 starts with P2's default keys (J/L/I/O/U/K/H)
	var p2_keys := P2_DEFAULT_KEYS.values()
	var p4_actions_list := P4_ACTIONS
	for i in p4_actions_list.size():
		_bind_key_to_action(p4_actions_list[i], p2_keys[i])


func _bind_key_to_action(action: String, keycode: Key) -> void:
	var ev := InputEventKey.new()
	ev.physical_keycode = keycode
	InputMap.action_add_event(action, ev)


# ─── Build Player Count Screen ────────────────────────────────────────────────

func _build_count_screen() -> void:
	_count_layer = CanvasLayer.new()
	_count_layer.layer = 10
	add_child(_count_layer)

	var backdrop := ColorRect.new()
	backdrop.color = Color(0, 0, 0, 0.80)
	backdrop.offset_right = VIEWPORT_W
	backdrop.offset_bottom = VIEWPORT_H
	_count_layer.add_child(backdrop)

	var title := _make_label("SMASH HERO ROCKIT", 42, Color.WHITE)
	title.offset_left = 0
	title.offset_top = 100
	title.offset_right = VIEWPORT_W
	title.offset_bottom = 160
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_count_layer.add_child(title)

	var subtitle := _make_label("How many players?", 26, Color(0.8, 0.85, 1.0))
	subtitle.offset_left = 0
	subtitle.offset_top = 180
	subtitle.offset_right = VIEWPORT_W
	subtitle.offset_bottom = 220
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_count_layer.add_child(subtitle)

	var box_w := 140.0
	var box_h := 120.0
	var gap := 50.0
	var total_w := 3 * box_w + 2 * gap
	var start_x := (VIEWPORT_W - total_w) / 2.0
	var box_y := 260.0

	_count_boxes.clear()
	_count_labels.clear()

	for i in 3:
		var box := ColorRect.new()
		box.offset_left = start_x + i * (box_w + gap)
		box.offset_top = box_y
		box.offset_right = box.offset_left + box_w
		box.offset_bottom = box_y + box_h
		box.color = Color(0.15, 0.18, 0.22, 0.95)
		_count_layer.add_child(box)
		_count_boxes.append(box)

		var lbl := _make_label(str(i + 2), 48, Color.WHITE)
		lbl.offset_left = box.offset_left
		lbl.offset_top = box_y + 10
		lbl.offset_right = box.offset_right
		lbl.offset_bottom = box_y + box_h - 10
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_count_layer.add_child(lbl)
		_count_labels.append(lbl)

	var hint := _make_label("← / → : Select   •   Attack / Jump : Confirm   •   Esc : Quit", 16, Color(0.6, 0.65, 0.7))
	hint.offset_left = 0
	hint.offset_top = 440
	hint.offset_right = VIEWPORT_W
	hint.offset_bottom = 470
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_count_layer.add_child(hint)


func _update_count_ui() -> void:
	for i in 3:
		if i == count_cursor:
			_count_boxes[i].color = Color(0.25, 0.5, 0.95, 0.95)
			_count_labels[i].add_theme_color_override("font_color", Color.WHITE)
		else:
			_count_boxes[i].color = Color(0.15, 0.18, 0.22, 0.95)
			_count_labels[i].add_theme_color_override("font_color", Color(0.5, 0.55, 0.6))


func _handle_count_input() -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
		return

	var changed := false
	# Any player can navigate
	for i in 4:
		var acts: Array = PLAYER_ACTION_SETS[i]
		if Input.is_action_just_pressed(acts[0]):  # left
			count_cursor = wrapi(count_cursor - 1, 0, 3)
			changed = true
		elif Input.is_action_just_pressed(acts[1]):  # right
			count_cursor = wrapi(count_cursor + 1, 0, 3)
			changed = true
	if changed:
		_update_count_ui()

	# Confirm
	for i in 4:
		var acts: Array = PLAYER_ACTION_SETS[i]
		if Input.is_action_just_pressed(acts[2]) or Input.is_action_just_pressed(acts[3]):  # jump or attack
			num_players = count_cursor + 2
			_show_phase(MenuPhase.CHARACTER_SELECT)
			return


# ─── Build Character Select Screen ────────────────────────────────────────────

func _build_char_screen() -> void:
	_char_layer = CanvasLayer.new()
	_char_layer.layer = 10
	add_child(_char_layer)

	var backdrop := ColorRect.new()
	backdrop.color = Color(0, 0, 0, 0.80)
	backdrop.offset_right = VIEWPORT_W
	backdrop.offset_bottom = VIEWPORT_H
	_char_layer.add_child(backdrop)

	_char_title = _make_label("CHARACTER SELECT", 32, Color.WHITE)
	_char_title.offset_left = 0
	_char_title.offset_top = 30
	_char_title.offset_right = VIEWPORT_W
	_char_title.offset_bottom = 75
	_char_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_char_layer.add_child(_char_title)

	_char_face_rects.clear()
	_char_name_labels.clear()
	_char_status_labels.clear()
	_char_control_labels.clear()
	_char_columns.clear()

	# Build 4 columns (show/hide based on num_players)
	for i in 4:
		var col := Control.new()
		_char_layer.add_child(col)
		_char_columns.append(col)

		# Face preview
		var face := TextureRect.new()
		face.custom_minimum_size = Vector2(100, 100)
		face.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		face.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		col.add_child(face)
		_char_face_rects.append(face)

		# Player name
		var name_lbl := _make_label("", 20, PLAYER_LABEL_COLORS[i])
		name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		col.add_child(name_lbl)
		_char_name_labels.append(name_lbl)

		# Status
		var status_lbl := _make_label("", 16, Color(0.7, 0.7, 0.7))
		status_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		col.add_child(status_lbl)
		_char_status_labels.append(status_lbl)

		# Controls
		var ctrl_lbl := _make_label("", 12, Color(0.55, 0.6, 0.65))
		ctrl_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		col.add_child(ctrl_lbl)
		_char_control_labels.append(ctrl_lbl)

	_char_hint = _make_label("", 15, Color(0.6, 0.65, 0.7))
	_char_hint.offset_left = 0
	_char_hint.offset_top = 570
	_char_hint.offset_right = VIEWPORT_W
	_char_hint.offset_bottom = 600
	_char_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_char_layer.add_child(_char_hint)


func _reset_char_select() -> void:
	for i in 4:
		char_locked[i] = false
	# Default: each player gets a different character
	for i in 4:
		char_indices[i] = i % CHARACTER_NAMES.size()
	# Ensure no two unlocked players start on a locked character
	for i in num_players:
		if _is_char_locked_by_other(i, char_indices[i]):
			char_indices[i] = _next_available_char(i, char_indices[i], 1)


func _layout_char_columns() -> void:
	var n := num_players
	var col_w := 220.0
	var total_w := n * col_w
	var gap := (VIEWPORT_W - total_w) / float(n + 1)

	for i in 4:
		var col: Control = _char_columns[i]
		col.visible = i < n
		if i >= n:
			continue

		var x := gap + i * (col_w + gap)
		var y := 95.0

		# Player header  (using a background swatch)
		var face: TextureRect = _char_face_rects[i]
		face.offset_left = x + (col_w - 100) / 2.0
		face.offset_top = y
		face.offset_right = face.offset_left + 100
		face.offset_bottom = y + 100

		var name_lbl: Label = _char_name_labels[i]
		name_lbl.offset_left = x
		name_lbl.offset_top = y + 110
		name_lbl.offset_right = x + col_w
		name_lbl.offset_bottom = y + 140

		var status_lbl: Label = _char_status_labels[i]
		status_lbl.offset_left = x
		status_lbl.offset_top = y + 145
		status_lbl.offset_right = x + col_w
		status_lbl.offset_bottom = y + 175

		var ctrl_lbl: Label = _char_control_labels[i]
		ctrl_lbl.offset_left = x
		ctrl_lbl.offset_top = y + 200
		ctrl_lbl.offset_right = x + col_w
		ctrl_lbl.offset_bottom = y + 320


func _update_char_ui() -> void:
	_layout_char_columns()
	_char_title.text = "CHARACTER SELECT  (%d Players)" % num_players

	for i in num_players:
		var idx: int = char_indices[i]
		var cname := CHARACTER_NAMES[idx]
		_char_name_labels[i].text = "P%d: %s" % [i + 1, cname]
		_char_name_labels[i].add_theme_color_override("font_color", PLAYER_LABEL_COLORS[i])

		if char_locked[i]:
			_char_status_labels[i].text = "LOCKED ✓"
			_char_status_labels[i].add_theme_color_override("font_color", Color(0.3, 1.0, 0.4))
		else:
			_char_status_labels[i].text = "← PICK →"
			_char_status_labels[i].add_theme_color_override("font_color", Color(0.9, 0.85, 0.3))

		_char_face_rects[i].texture = _get_menu_character_texture(idx, "attack" if char_locked[i] else "face")
		if num_players <= 2:
			_char_control_labels[i].text = CONTROLS_2P[i] if i < CONTROLS_2P.size() else ""
		else:
			_char_control_labels[i].text = CONTROLS_MULTI[i] if i < CONTROLS_MULTI.size() else ""

	_char_hint.text = "Left/Right: Pick • Attack/Jump: Lock • Jump: Unlock • Vapor: Back • Esc: Quit"


func _is_char_locked_by_other(player_idx: int, char_idx: int) -> bool:
	for j in num_players:
		if j != player_idx and char_locked[j] and char_indices[j] == char_idx:
			return true
	return false


func _next_available_char(player_idx: int, current: int, direction: int) -> int:
	var total := CHARACTER_NAMES.size()
	for _step in total:
		current = wrapi(current + direction, 0, total)
		if not _is_char_locked_by_other(player_idx, current):
			return current
	# Fallback (all taken – shouldn't happen with 4 chars / max 4 players)
	return current


func _handle_char_input() -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		_show_phase(MenuPhase.PLAYER_COUNT)
		return

	# Vapor from any player: go back to player count
	for i in num_players:
		var acts: Array = PLAYER_ACTION_SETS[i]
		if Input.is_action_just_pressed(acts[4]):  # vapor
			_show_phase(MenuPhase.PLAYER_COUNT)
			return

	var changed := false

	for i in num_players:
		var acts: Array = PLAYER_ACTION_SETS[i]
		if not char_locked[i]:
			if Input.is_action_just_pressed(acts[0]):  # left
				char_indices[i] = _next_available_char(i, char_indices[i], -1)
				changed = true
			elif Input.is_action_just_pressed(acts[1]):  # right
				char_indices[i] = _next_available_char(i, char_indices[i], 1)
				changed = true
			if Input.is_action_just_pressed(acts[3]) or Input.is_action_just_pressed(acts[2]):  # attack or jump
				if not _is_char_locked_by_other(i, char_indices[i]):
					char_locked[i] = true
					changed = true
		else:
			# Unlock with jump
			if Input.is_action_just_pressed(acts[2]):  # jump
				char_locked[i] = false
				changed = true

	if changed:
		_update_char_ui()

	# Check if all locked → advance to arena select
	var all_locked := true
	for i in num_players:
		if not char_locked[i]:
			all_locked = false
			break
	if all_locked:
		_show_phase(MenuPhase.ARENA_SELECT)


# ─── Build Arena Select Screen ────────────────────────────────────────────────

func _build_arena_screen() -> void:
	_arena_layer = CanvasLayer.new()
	_arena_layer.layer = 10
	add_child(_arena_layer)

	var backdrop := ColorRect.new()
	backdrop.color = Color(0, 0, 0, 0.85)
	backdrop.offset_right = VIEWPORT_W
	backdrop.offset_bottom = VIEWPORT_H
	_arena_layer.add_child(backdrop)

	_arena_title = _make_label("SELECT YOUR ARENA", 36, Color.WHITE)
	_arena_title.offset_left = 0
	_arena_title.offset_top = 40
	_arena_title.offset_right = VIEWPORT_W
	_arena_title.offset_bottom = 90
	_arena_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_arena_layer.add_child(_arena_title)

	_arena_cards.clear()
	_arena_card_labels.clear()
	_arena_card_bg_holders.clear()
	_arena_card_glows.clear()

	var card_w := 300.0
	var card_h := 280.0
	var gap := 50.0
	var total_w := ARENA_NAMES.size() * card_w + (ARENA_NAMES.size() - 1) * gap
	var start_x := (VIEWPORT_W - total_w) / 2.0
	var card_y := 120.0

	for i in ARENA_NAMES.size():
		var card := ColorRect.new()
		card.offset_left = start_x + i * (card_w + gap)
		card.offset_top = card_y
		card.offset_right = card.offset_left + card_w
		card.offset_bottom = card_y + card_h
		card.color = Color(0.12, 0.14, 0.18, 0.95)
		card.clip_children = CanvasItem.CLIP_CHILDREN_ONLY
		_arena_layer.add_child(card)
		_arena_cards.append(card)

		# Arena name label
		var name_lbl := _make_label(ARENA_NAMES[i], 22, Color.WHITE)
		name_lbl.offset_left = card.offset_left
		name_lbl.offset_top = card_y + 8
		name_lbl.offset_right = card.offset_right
		name_lbl.offset_bottom = card_y + 40
		name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_arena_layer.add_child(name_lbl)
		_arena_card_labels.append(name_lbl)

		# Background preview holder (scaled down inside the card)
		var bg_holder := Node2D.new()
		bg_holder.position = Vector2(card.offset_left, card_y + 45)
		bg_holder.scale = Vector2(card_w / VIEWPORT_W, (card_h - 50) / VIEWPORT_H)
		_arena_layer.add_child(bg_holder)
		_arena_card_bg_holders.append(bg_holder)

		var thumb_glow := ColorRect.new()
		thumb_glow.offset_left = card.offset_left
		thumb_glow.offset_top = card_y + 45
		thumb_glow.offset_right = card.offset_right
		thumb_glow.offset_bottom = card_y + card_h
		thumb_glow.color = Color(1.0, 1.0, 0.7, 0.0)
		_arena_layer.add_child(thumb_glow)
		_arena_card_glows.append(thumb_glow)

		# Platform indicators
		_add_arena_card_platforms(i, card.offset_left, card_y + 45, card_w, card_h - 50)

	_arena_hint = _make_label("← / → : Browse   •   Attack / Jump : Confirm   •   Vapor : Back", 16, Color(0.6, 0.65, 0.7))
	_arena_hint.offset_left = 0
	_arena_hint.offset_top = 460
	_arena_hint.offset_right = VIEWPORT_W
	_arena_hint.offset_bottom = 490
	_arena_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_arena_layer.add_child(_arena_hint)

	# Load preview backgrounds
	_load_arena_preview_bgs()


func _add_arena_card_platforms(arena_idx: int, cx: float, cy: float, cw: float, ch: float) -> void:
	# Draw simple platform rectangles as indicators in the arena card
	var scale_x := cw / VIEWPORT_W
	var scale_y := ch / VIEWPORT_H

	var positions: Array
	var sizes: Array
	var rotations: Array
	match arena_idx:
		0:  # Classic
			positions = [Vector2(350, 480), Vector2(700, 380), Vector2(450, 280)]
			sizes = [Vector2(200, 12), Vector2(160, 12), Vector2(200, 12)]
			rotations = [0.0, 0.0, 0.0]
		1:  # Sky Bridge
			positions = [Vector2(300, 500), Vector2(576, 420), Vector2(850, 340)]
			sizes = [Vector2(200, 12), Vector2(160, 12), Vector2(200, 12)]
			rotations = [0.0, 0.0, 0.0]
		2:  # Pitfall
			positions = [Vector2(320, 500), Vector2(576, 420), Vector2(832, 500)]
			sizes = [Vector2(200, 12), Vector2(200, 12), Vector2(200, 12)]
			rotations = [0.0, -18.0, 0.0]

	for j in 3:
		if sizes[j] == Vector2.ZERO:
			continue
		var plat := ColorRect.new()
		var scaled_w: float = sizes[j].x * scale_x
		var scaled_h: float = sizes[j].y * scale_y
		plat.offset_left = cx + (positions[j].x - sizes[j].x / 2.0) * scale_x
		plat.offset_top = cy + positions[j].y * scale_y
		plat.offset_right = plat.offset_left + scaled_w
		plat.offset_bottom = plat.offset_top + scaled_h
		plat.pivot_offset = Vector2(scaled_w * 0.5, scaled_h * 0.5)
		plat.rotation_degrees = rotations[j]
		plat.color = ARENA_PLAT_COLORS[arena_idx]
		_arena_layer.add_child(plat)

	if arena_idx == 2:
		var floor_left := ColorRect.new()
		floor_left.offset_left = cx + (391.0 - 115.0) * scale_x
		floor_left.offset_top = cy + 584.0 * scale_y
		floor_left.offset_right = cx + (391.0 + 115.0) * scale_x
		floor_left.offset_bottom = cy + 616.0 * scale_y
		floor_left.color = ARENA_FLOOR_COLORS[arena_idx]
		_arena_layer.add_child(floor_left)

		var floor_right := ColorRect.new()
		floor_right.offset_left = cx + (761.0 - 115.0) * scale_x
		floor_right.offset_top = cy + 584.0 * scale_y
		floor_right.offset_right = cx + (761.0 + 115.0) * scale_x
		floor_right.offset_bottom = cy + 616.0 * scale_y
		floor_right.color = ARENA_FLOOR_COLORS[arena_idx]
		_arena_layer.add_child(floor_right)
	else:
		# Floor (per-arena width)
		var fhw: float = ARENA_FLOOR_HALF_WIDTHS[arena_idx]
		var floor_rect := ColorRect.new()
		floor_rect.offset_left = cx + (FLOOR_CENTER_X - fhw) * scale_x
		floor_rect.offset_top = cy + 584.0 * scale_y
		floor_rect.offset_right = cx + (FLOOR_CENTER_X + fhw) * scale_x
		floor_rect.offset_bottom = cy + 616.0 * scale_y
		floor_rect.color = ARENA_FLOOR_COLORS[arena_idx]
		_arena_layer.add_child(floor_rect)


func _load_arena_preview_bgs() -> void:
	for i in ARENA_NAMES.size():
		var scene := load(ARENA_BG_SCENES[i]) as PackedScene
		if scene:
			var inst := scene.instantiate()
			_arena_card_bg_holders[i].add_child(inst)
			_arena_preview_bgs[i] = inst


func _update_arena_ui() -> void:
	for i in ARENA_NAMES.size():
		if i == arena_cursor:
			_arena_cards[i].color = Color(0.2, 0.35, 0.65, 0.95)
			_arena_card_labels[i].add_theme_color_override("font_color", Color(1.0, 1.0, 0.7))
			_arena_card_bg_holders[i].modulate = Color(1.0, 1.0, 1.0, 1.0)
			_arena_card_glows[i].color = Color(1.0, 1.0, 0.7, 0.18)
		else:
			_arena_cards[i].color = Color(0.12, 0.14, 0.18, 0.95)
			_arena_card_labels[i].add_theme_color_override("font_color", Color(0.6, 0.65, 0.7))
			_arena_card_bg_holders[i].modulate = Color(0.72, 0.72, 0.78, 0.95)
			_arena_card_glows[i].color = Color(1.0, 1.0, 0.7, 0.0)


func _handle_arena_input() -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		_show_phase(MenuPhase.CHARACTER_SELECT)
		return

	# Vapor from any player: go back to character select
	for i in num_players:
		var acts: Array = PLAYER_ACTION_SETS[i]
		if Input.is_action_just_pressed(acts[4]):  # vapor
			_show_phase(MenuPhase.CHARACTER_SELECT)
			return

	var changed := false
	for i in num_players:
		var acts: Array = PLAYER_ACTION_SETS[i]
		if Input.is_action_just_pressed(acts[0]):  # left
			arena_cursor = wrapi(arena_cursor - 1, 0, ARENA_NAMES.size())
			changed = true
		elif Input.is_action_just_pressed(acts[1]):  # right
			arena_cursor = wrapi(arena_cursor + 1, 0, ARENA_NAMES.size())
			changed = true

	if changed:
		_update_arena_ui()

	# Confirm: any player
	for i in num_players:
		var acts: Array = PLAYER_ACTION_SETS[i]
		if Input.is_action_just_pressed(acts[2]) or Input.is_action_just_pressed(acts[3]):  # jump or attack
			_start_match_with_selection()
			return


# ─── Match Start / Game Flow ──────────────────────────────────────────────────

func _start_match_with_selection() -> void:
	# Apply characters to active players
	for i in num_players:
		_apply_character_to_player(all_players[i], char_indices[i])

	# Set faces in HUD
	for i in num_players:
		var p: Node = all_players[i]
		if p.has_method("get_expression_texture"):
			hud.set_player_face(i, p.get_expression_texture("face"))

	selected_arena_index = arena_cursor
	_apply_arena(selected_arena_index)

	# Hide all menu layers
	_count_layer.visible = false
	_char_layer.visible = false
	_arena_layer.visible = false

	_start_game()


func _start_game() -> void:
	is_result_active = false
	end_screen.visible = false
	menu_phase = MenuPhase.NONE
	hud.visible = true
	hud.configure_for_players(num_players)
	_apply_keyboard_layout_for_player_count()
	elimination_order.clear()

	# Reset stocks tracking
	for i in 4:
		previous_stocks[i] = PLAYER_MAX_STOCKS
		eliminated_players[i] = false

	# Set spawn positions
	var spawns := _compute_spawn_positions(num_players, selected_arena_index)
	for i in num_players:
		all_players[i].spawn_position = spawns[i]

	_reset_players_for_round()
	_set_gameplay_enabled(true)


func _reset_players_for_round() -> void:
	for i in num_players:
		if all_players[i].has_method("reset_for_round"):
			all_players[i].reset_for_round()


func _set_gameplay_enabled(enabled: bool) -> void:
	for i in 4:
		var player_enabled := enabled and i < num_players
		if all_players[i].has_method("set_round_active"):
			all_players[i].set_round_active(player_enabled)
		else:
			all_players[i].visible = player_enabled
			all_players[i].set_physics_process(player_enabled)
	hazard_spawner.set_process(enabled)


func _handle_in_fight_input() -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		_return_to_main_menu()


# ─── Player Elimination / Game End ─────────────────────────────────────────────

func _on_player_eliminated(player_index: int) -> void:
	if menu_phase != MenuPhase.NONE or is_result_active:
		return
	if not elimination_order.has(player_index):
		elimination_order.append(player_index)
	eliminated_players[player_index] = true

	var alive: Array[int] = []
	for i in num_players:
		if not eliminated_players[i]:
			alive.append(i)

	if alive.size() == 1:
		_handle_game_end(alive[0])
	elif alive.size() == 0:
		# Edge case: simultaneous elimination, pick the last one
		_handle_game_end(player_index)


func _on_player_stock_changed(stocks: int, player_index: int) -> void:
	if menu_phase != MenuPhase.NONE:
		return
	_handle_stock_audio(stocks, previous_stocks[player_index])
	previous_stocks[player_index] = stocks


func _handle_stock_audio(stocks: int, prev: int) -> void:
	if stocks >= prev:
		return
	if stocks == 1:
		_play_sound(finish_him_player)


func _on_player_got_hit(next_stocks: int, caused_stock_loss: bool) -> void:
	if menu_phase != MenuPhase.NONE:
		return
	if next_stocks <= 0:
		return
	if caused_stock_loss and next_stocks == 1:
		return
	_play_sound(wilhelm_player)


func _on_player_fell_out(next_stocks: int) -> void:
	if menu_phase != MenuPhase.NONE:
		return
	if next_stocks <= 0:
		return
	if next_stocks == 1:
		return
	_play_sound(chevre_player)


func _on_player_jumped() -> void:
	if menu_phase != MenuPhase.NONE or is_result_active:
		return
	_play_sound(jump_player)


func _handle_game_end(winner_index: int) -> void:
	is_result_active = true
	result_input_delay = RESULT_MIN_DISPLAY
	_set_gameplay_enabled(false)

	var winner_name := "P%d" % (winner_index + 1)
	var winner_color := Color(CHARACTER_COLORS[char_indices[winner_index]], 0.88)

	_show_end_screen("K.O.", "%s WINS!" % winner_name, winner_color, "", "Attack/Jump: Rematch   Vapor: Main Menu")
	_update_end_screen_faces(winner_index)
	_play_sound(victory_player)


# ─── End Screen ────────────────────────────────────────────────────────────────

func _show_end_screen(title: String, subtitle: String, tint: Color, score_text: String, hint_text: String) -> void:
	end_screen.visible = true
	hud.visible = false
	end_title.text = title
	end_subtitle.text = subtitle
	end_score.text = score_text
	end_arena.text = "Arena: %s" % ARENA_NAMES[selected_arena_index]
	end_hint.text = hint_text
	end_backdrop.color = tint


func _update_end_screen_faces(winner_index: int) -> void:
	_clear_end_loser_thumbnails()
	var winner_node: Node = all_players[winner_index]

	winner_tag.text = "WINNER P%d" % (winner_index + 1)
	winner_face.texture = _get_player_expression_texture(winner_node, "victory")
	winner_face.visible = winner_face.texture != null

	var loser_indices: Array[int] = []
	for i in num_players:
		if i != winner_index:
			loser_indices.append(i)

	var loser_index := -1
	for idx in elimination_order:
		if idx != winner_index:
			loser_index = idx
			break
	if loser_index < 0 and loser_indices.size() > 0:
		loser_index = loser_indices[0]

	if loser_index >= 0:
		var loser_node: Node = all_players[loser_index]
		loser_tag.text = "BIGGEST LOSER P%d" % (loser_index + 1) if num_players > 2 else "LOSER P%d" % (loser_index + 1)
		loser_face.texture = _get_player_expression_texture(loser_node, "defeat")
		if loser_face.texture == null:
			loser_face.texture = _get_player_expression_texture(loser_node, "face")
		loser_face.visible = loser_face.texture != null
		loser_tag.visible = true

		if num_players > 2:
			var loser_names: Array[String] = []
			for idx in loser_indices:
				loser_names.append("P%d" % (idx + 1))
			end_score.text = "Losers: %s" % " • ".join(loser_names)
			_update_end_loser_thumbnails(loser_indices, loser_index)
		else:
			end_score.text = ""
	else:
		loser_face.visible = false
		loser_tag.visible = false
		end_score.text = ""


func _clear_end_loser_thumbnails() -> void:
	for node in _end_loser_extra_nodes:
		if is_instance_valid(node):
			node.queue_free()
	_end_loser_extra_nodes.clear()


func _update_end_loser_thumbnails(loser_indices: Array[int], biggest_loser_index: int) -> void:
	if num_players <= 2 or loser_indices.is_empty():
		return

	var ordered_losers: Array[int] = []
	if biggest_loser_index >= 0 and loser_indices.has(biggest_loser_index):
		ordered_losers.append(biggest_loser_index)
	for idx in elimination_order:
		if idx != biggest_loser_index and loser_indices.has(idx) and not ordered_losers.has(idx):
			ordered_losers.append(idx)
	for idx in loser_indices:
		if not ordered_losers.has(idx):
			ordered_losers.append(idx)

	var x := 634.0
	var y_start := 186.0
	var y_step := 68.0
	for i in ordered_losers.size():
		var idx := ordered_losers[i]
		var y := y_start + i * y_step

		var frame := ColorRect.new()
		frame.offset_left = x
		frame.offset_top = y
		frame.offset_right = x + 60.0
		frame.offset_bottom = y + 60.0
		frame.color = Color(1.0, 0.82, 0.22, 0.92) if idx == biggest_loser_index else Color(0.40, 0.16, 0.16, 0.92)
		end_panel.add_child(frame)
		_end_loser_extra_nodes.append(frame)

		var face := TextureRect.new()
		face.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		face.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		face.offset_left = x + 2.0
		face.offset_top = y + 2.0
		face.offset_right = x + 58.0
		face.offset_bottom = y + 58.0
		var loser_node: Node = all_players[idx]
		face.texture = _get_player_expression_texture(loser_node, "defeat")
		if face.texture == null:
			face.texture = _get_player_expression_texture(loser_node, "face")
		end_panel.add_child(face)
		_end_loser_extra_nodes.append(face)

		var label := _make_label("P%d" % (idx + 1), 12, Color(1.0, 0.9, 0.9))
		label.offset_left = x
		label.offset_top = y + 60.0
		label.offset_right = x + 60.0
		label.offset_bottom = y + 76.0
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		end_panel.add_child(label)
		_end_loser_extra_nodes.append(label)


func _get_player_expression_texture(player_node: Node, expression: String) -> Texture2D:
	if player_node.has_method("get_expression_texture"):
		return player_node.get_expression_texture(expression)
	return null


func _handle_result_input() -> void:
	if result_input_delay > 0.0:
		return
	if Input.is_action_just_pressed("ui_cancel"):
		_return_to_main_menu()
		return

	# Vapor: return to main menu
	for i in num_players:
		var acts: Array = PLAYER_ACTION_SETS[i]
		if Input.is_action_just_pressed(acts[4]):  # vapor
			_return_to_main_menu()
			return

	# Confirm: rematch
	for i in num_players:
		var acts: Array = PLAYER_ACTION_SETS[i]
		if Input.is_action_just_pressed(acts[2]) or Input.is_action_just_pressed(acts[3]):  # jump or attack
			_start_game()
			return


func _return_to_main_menu() -> void:
	is_result_active = false
	result_input_delay = 0.0
	end_screen.visible = false
	_set_gameplay_enabled(false)
	hud.visible = false
	_show_phase(MenuPhase.PLAYER_COUNT)


# ─── Audio ─────────────────────────────────────────────────────────────────────

func _setup_audio_players() -> void:
	chevre_player = _create_sfx_player(_load_mp3_stream(SFX_CHEVRE_PATH))
	wilhelm_player = _create_sfx_player(_load_mp3_stream(SFX_WILHELM_PATH))
	finish_him_player = _create_sfx_player(_load_mp3_stream(SFX_FINISH_HIM_PATH))
	victory_player = _create_sfx_player(_load_mp3_stream(SFX_VICTORY_PATH))
	jump_player = _create_sfx_player(_load_mp3_stream(SFX_JUMP_PATH))


func _create_sfx_player(stream: AudioStream) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.stream = stream
	add_child(player)
	return player


func _load_mp3_stream(path: String) -> AudioStream:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null
	var stream := AudioStreamMP3.new()
	stream.data = file.get_buffer(file.get_length())
	return stream


func _play_sound(player: AudioStreamPlayer) -> void:
	if player == null or player.stream == null:
		return
	player.stop()
	player.play()


# ─── Arena / Background Management ────────────────────────────────────────────

func _apply_arena(arena_index: int) -> void:
	_set_platform_enabled(platform_1, platform_1_shape, platform_1_visual, true)
	_set_platform_enabled(platform_2, platform_2_shape, platform_2_visual, true)
	_set_platform_enabled(platform_3, platform_3_shape, platform_3_visual, true)
	_set_floor_split_enabled(false)
	platform_1.rotation = 0.0
	platform_2.rotation = 0.0
	platform_3.rotation = 0.0
	platform_1.scale = Vector2.ONE
	platform_2.scale = Vector2.ONE
	platform_3.scale = Vector2.ONE

	_resize_floor(ARENA_FLOOR_HALF_WIDTHS[arena_index])
	_swap_background(arena_index)
	_apply_arena_colors(arena_index)

	match arena_index:
		0:
			platform_1.position = Vector2(350, 480)
			platform_2.position = Vector2(700, 380)
			platform_3.position = Vector2(450, 280)
		1:
			platform_1.position = Vector2(300, 500)
			platform_2.position = Vector2(576, 420)
			platform_3.position = Vector2(850, 340)
		2:
			platform_1.position = Vector2(320, 500)
			platform_2.position = Vector2(576, 420)
			platform_3.position = Vector2(832, 500)
			platform_2.rotation_degrees = -18.0
			platform_2.scale = Vector2(1.25, 1.0)
			_set_floor_split_enabled(true)


func _swap_background(arena_index: int) -> void:
	if _current_bg != null:
		_current_bg.queue_free()
		_current_bg = null
	var scene := load(ARENA_BG_SCENES[arena_index]) as PackedScene
	if scene:
		_current_bg = scene.instantiate()
		bg_container.add_child(_current_bg)


func _apply_arena_colors(arena_index: int) -> void:
	var floor_c := ARENA_FLOOR_COLORS[arena_index]
	var moss_c := ARENA_MOSS_COLORS[arena_index]
	var plat_c := ARENA_PLAT_COLORS[arena_index]
	var plat_m := ARENA_PLAT_MOSS_COLORS[arena_index]
	floor_visual.color = floor_c
	floor_moss.color = moss_c
	floor_left_visual.color = floor_c
	floor_left_moss.color = moss_c
	floor_right_visual.color = floor_c
	floor_right_moss.color = moss_c
	platform_1_visual.color = plat_c
	platform_1_moss.color = plat_m
	platform_2_visual.color = plat_c
	platform_2_moss.color = plat_m
	platform_3_visual.color = plat_c
	platform_3_moss.color = plat_m


func _compute_spawn_positions(player_count: int, arena_index: int) -> Array[Vector2]:
	var hw: float = ARENA_FLOOR_HALF_WIDTHS[arena_index]
	var margin := 60.0
	var left_x := FLOOR_CENTER_X - hw + margin
	var right_x := FLOOR_CENTER_X + hw - margin
	var positions: Array[Vector2] = []
	if player_count == 1:
		positions.append(Vector2(FLOOR_CENTER_X, SPAWN_Y))
	elif player_count == 2:
		positions.append(Vector2(left_x, SPAWN_Y))
		positions.append(Vector2(right_x, SPAWN_Y))
	else:
		for i in player_count:
			var t := float(i) / float(player_count - 1)
			positions.append(Vector2(lerpf(left_x, right_x, t), SPAWN_Y))
	return positions


func _resize_floor(half_width: float) -> void:
	var shape_res := floor_shape.shape as RectangleShape2D
	shape_res.size = Vector2(half_width * 2.0, 32.0)
	floor_visual.offset_left = -half_width
	floor_visual.offset_right = half_width
	floor_moss.offset_left = -half_width
	floor_moss.offset_right = half_width


func _set_floor_split_enabled(enabled: bool) -> void:
	floor_body.visible = not enabled
	floor_shape.disabled = enabled
	floor_left_body.visible = enabled
	floor_left_shape.disabled = not enabled
	floor_right_body.visible = enabled
	floor_right_shape.disabled = not enabled


func _set_platform_enabled(platform_node: Node2D, platform_shape: CollisionShape2D, platform_visual: CanvasItem, enabled: bool) -> void:
	platform_node.visible = enabled
	platform_shape.disabled = not enabled
	if platform_visual != null:
		platform_visual.visible = enabled


# ─── Character / Asset Management ──────────────────────────────────────────────

func _apply_character_to_player(player_node: Node, character_index: int) -> void:
	var color := CHARACTER_COLORS[character_index]
	var prefix := CHARACTER_ASSET_PREFIXES[character_index]
	if player_node.has_method("apply_character_profile"):
		player_node.apply_character_profile(color, prefix)
	elif player_node.has_method("apply_character_color"):
		player_node.apply_character_color(color)


func _build_menu_asset_lookup() -> void:
	menu_asset_lookup.clear()
	var dir := DirAccess.open("res://assets")
	if dir == null:
		return
	for file_name in dir.get_files():
		var ext := file_name.get_extension().to_lower()
		if ext not in ["png", "jpg", "jpeg", "webp"]:
			continue
		var normalized := _normalize_asset_name(file_name.get_basename())
		menu_asset_lookup[normalized] = "res://assets/%s" % file_name


func _get_menu_character_texture(character_index: int, expression: String) -> Texture2D:
	for prefix in _character_prefix_variants(CHARACTER_ASSET_PREFIXES[character_index]):
		for state in [expression, "face"]:
			var key := _normalize_asset_name("%s_%s" % [prefix, state])
			var path: String = menu_asset_lookup.get(key, "")
			if not path.is_empty():
				var texture := _try_load_menu_texture(path)
				if texture != null:
					return texture
	return null


func _character_prefix_variants(prefix: String) -> Array[String]:
	var variants: Array[String] = [prefix]
	var normalized := _normalize_asset_name(prefix)
	if normalized == "tommy":
		variants.append("Toomy")
	if normalized == "yves_henri":
		variants.append("Yves-Henry")
	return variants


func _try_load_menu_texture(path: String) -> Texture2D:
	if not FileAccess.file_exists(path):
		return null
	var image := Image.new()
	if image.load(path) != OK:
		return null
	var texture := ImageTexture.create_from_image(image)
	return texture


func _normalize_asset_name(asset_name: String) -> String:
	return asset_name.to_lower().replace("-", "_")


# ─── Joypad / Input Management ────────────────────────────────────────────────

func _on_joy_connection_changed(_device: int, _connected: bool) -> void:
	_refresh_joypad_mapping()


func _refresh_joypad_mapping() -> void:
	var connected := Input.get_connected_joypads()
	if connected.is_empty():
		print("No joypads detected.")
		_print_wsl_input_hint()
		_print_snap_joystick_hint()
		return

	var names: PackedStringArray = []
	for joy_id in connected:
		names.append("%d:%s" % [joy_id, Input.get_joy_name(joy_id)])
	print("Connected joypads -> ", ", ".join(names))

	if connected.size() >= 1:
		_force_joypad_bindings(P1_ACTIONS, connected[0])
		print("Mapped P1 gamepad to device %d" % connected[0])
	if connected.size() >= 2:
		_force_joypad_bindings(P2_ACTIONS, connected[1])
		print("Mapped P2 gamepad to device %d" % connected[1])

	_strip_joypad_events(P3_ACTIONS)
	_strip_joypad_events(P4_ACTIONS)


func _print_snap_joystick_hint() -> void:
	var is_snap := not OS.get_environment("SNAP").is_empty()
	if not is_snap:
		return
	print("Snap build detected. If your remote is not detected, run:")
	print("  sudo snap connect godot4:joystick")
	print("  sudo snap connect godot4:hardware-observe")


func _print_wsl_input_hint() -> void:
	var release := OS.get_environment("WSL_DISTRO_NAME")
	if release.is_empty():
		return
	print("WSL detected. /dev/input is typically unavailable.")


const JOY_BINDINGS: Dictionary = {
	"left":   {"buttons": [JOY_BUTTON_DPAD_LEFT],  "axes": [[JOY_AXIS_LEFT_X, -1.0]]},
	"right":  {"buttons": [JOY_BUTTON_DPAD_RIGHT], "axes": [[JOY_AXIS_LEFT_X, 1.0]]},
	"jump":   {"buttons": [JOY_BUTTON_A],          "axes": []},
	"attack": {"buttons": [JOY_BUTTON_X],          "axes": []},
	"vapor":  {"buttons": [JOY_BUTTON_Y],          "axes": []},
	"puddle": {"buttons": [JOY_BUTTON_B],          "axes": []},
	"dash":   {"buttons": [JOY_BUTTON_RIGHT_SHOULDER], "axes": []},
}


func _force_joypad_bindings(actions: Array[String], device: int) -> void:
	for action in actions:
		var events := InputMap.action_get_events(action)
		InputMap.action_erase_events(action)
		for event in events:
			if not (event is InputEventJoypadButton or event is InputEventJoypadMotion):
				InputMap.action_add_event(action, event)

		var suffix := action.split("_", false)
		var key := "_".join(suffix.slice(1))
		if not JOY_BINDINGS.has(key):
			continue
		var binding: Dictionary = JOY_BINDINGS[key]
		for btn in binding["buttons"]:
			var ev := InputEventJoypadButton.new()
			ev.button_index = btn
			ev.device = device
			InputMap.action_add_event(action, ev)
		for axis_pair in binding["axes"]:
			var ev := InputEventJoypadMotion.new()
			ev.axis = axis_pair[0]
			ev.axis_value = axis_pair[1]
			ev.device = device
			InputMap.action_add_event(action, ev)


func _strip_joypad_events(actions: Array[String]) -> void:
	for action in actions:
		if not InputMap.has_action(action):
			continue
		var events := InputMap.action_get_events(action)
		InputMap.action_erase_events(action)
		for event in events:
			if not (event is InputEventJoypadButton or event is InputEventJoypadMotion):
				InputMap.action_add_event(action, event)


const P1_DEFAULT_KEYS: Dictionary = {
	"p1_left": KEY_A, "p1_right": KEY_D, "p1_jump": KEY_W,
	"p1_attack": KEY_E, "p1_vapor": KEY_Q, "p1_puddle": KEY_S, "p1_dash": KEY_R,
}
const P2_DEFAULT_KEYS: Dictionary = {
	"p2_left": KEY_J, "p2_right": KEY_L, "p2_jump": KEY_I,
	"p2_attack": KEY_O, "p2_vapor": KEY_U, "p2_puddle": KEY_K, "p2_dash": KEY_H,
}
const P1_DUMMY_KEYS: Dictionary = {
	"p1_left": KEY_F1, "p1_right": KEY_F2, "p1_jump": KEY_F3,
	"p1_attack": KEY_F4, "p1_vapor": KEY_F5, "p1_puddle": KEY_F6, "p1_dash": KEY_PAUSE,
}
const P2_DUMMY_KEYS: Dictionary = {
	"p2_left": KEY_F7, "p2_right": KEY_F8, "p2_jump": KEY_F9,
	"p2_attack": KEY_F10, "p2_vapor": KEY_F11, "p2_puddle": KEY_F12, "p2_dash": KEY_PRINT,
}

func _apply_keyboard_layout_for_player_count() -> void:
	if num_players <= 2:
		return
	# P3 gets P1's default keyboard keys
	_replace_keyboard_events(P3_ACTIONS, P1_DEFAULT_KEYS.values())
	# P4 gets P2's default keyboard keys
	_replace_keyboard_events(P4_ACTIONS, P2_DEFAULT_KEYS.values())
	# P1 gets dummy keys (gamepad only in practice)
	_replace_keyboard_events(P1_ACTIONS, P1_DUMMY_KEYS.values())
	# P2 gets dummy keys (gamepad only in practice)
	_replace_keyboard_events(P2_ACTIONS, P2_DUMMY_KEYS.values())
	print("Multi-player keyboard layout applied: P3=WASD/QES, P4=IJKL/UOK, P1/P2=gamepad only")


func _restore_default_keyboard_layout() -> void:
	_replace_keyboard_events(P1_ACTIONS, P1_DEFAULT_KEYS.values())
	_replace_keyboard_events(P2_ACTIONS, P2_DEFAULT_KEYS.values())
	# Strip keyboard from P3/P4 and re-register their original keys
	_strip_keyboard_events(P3_ACTIONS)
	_strip_keyboard_events(P4_ACTIONS)
	_register_extra_actions()
	print("Default keyboard layout restored")


func _replace_keyboard_events(actions: Array[String], keys: Array) -> void:
	for i in actions.size():
		var action: String = actions[i]
		var events := InputMap.action_get_events(action)
		InputMap.action_erase_events(action)
		for event in events:
			if not (event is InputEventKey):
				InputMap.action_add_event(action, event)
		var ev := InputEventKey.new()
		ev.physical_keycode = keys[i]
		InputMap.action_add_event(action, ev)


func _strip_keyboard_events(actions: Array[String]) -> void:
	for action in actions:
		if not InputMap.has_action(action):
			continue
		var events := InputMap.action_get_events(action)
		InputMap.action_erase_events(action)
		for event in events:
			if not (event is InputEventKey):
				InputMap.action_add_event(action, event)


func _ensure_remote_fallback_bindings() -> void:
	_bind_key_if_missing("p1_vapor", KEY_Q)
	_bind_key_if_missing("p1_puddle", KEY_S)

	for p_idx in 4:
		var prefix := "p%d" % (p_idx + 1)
		_bind_joy_button_if_missing("%s_left" % prefix, JOY_BUTTON_DPAD_LEFT, p_idx)
		_bind_joy_button_if_missing("%s_right" % prefix, JOY_BUTTON_DPAD_RIGHT, p_idx)
		_bind_joy_button_if_missing("%s_jump" % prefix, JOY_BUTTON_A, p_idx)
		_bind_joy_button_if_missing("%s_attack" % prefix, JOY_BUTTON_X, p_idx)
		_bind_joy_button_if_missing("%s_vapor" % prefix, JOY_BUTTON_Y, p_idx)
		_bind_joy_button_if_missing("%s_puddle" % prefix, JOY_BUTTON_B, p_idx)
		_bind_joy_button_if_missing("%s_dash" % prefix, JOY_BUTTON_RIGHT_SHOULDER, p_idx)
		_bind_joy_motion_if_missing("%s_left" % prefix, JOY_AXIS_LEFT_X, -1.0, p_idx)
		_bind_joy_motion_if_missing("%s_right" % prefix, JOY_AXIS_LEFT_X, 1.0, p_idx)


func _bind_key_if_missing(action: String, keycode: Key) -> void:
	if not InputMap.has_action(action):
		return
	for event in InputMap.action_get_events(action):
		if event is InputEventKey and event.keycode == keycode:
			return
	var key_event := InputEventKey.new()
	key_event.keycode = keycode
	InputMap.action_add_event(action, key_event)


func _bind_joy_button_if_missing(action: String, button: JoyButton, device: int) -> void:
	if not InputMap.has_action(action):
		return
	for event in InputMap.action_get_events(action):
		if event is InputEventJoypadButton and event.button_index == button and event.device == device:
			return
	var button_event := InputEventJoypadButton.new()
	button_event.button_index = button
	button_event.device = device
	InputMap.action_add_event(action, button_event)


func _bind_joy_motion_if_missing(action: String, axis: JoyAxis, axis_value: float, device: int) -> void:
	if not InputMap.has_action(action):
		return
	for event in InputMap.action_get_events(action):
		if event is InputEventJoypadMotion and event.axis == axis and is_equal_approx(event.axis_value, axis_value) and event.device == device:
			return
	var motion_event := InputEventJoypadMotion.new()
	motion_event.axis = axis
	motion_event.axis_value = axis_value
	motion_event.device = device
	InputMap.action_add_event(action, motion_event)


# ─── Utility ──────────────────────────────────────────────────────────────────

func _make_label(text: String, font_size: int, color: Color = Color.WHITE) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", font_size)
	lbl.add_theme_color_override("font_color", color)
	return lbl


func _unhandled_input(event: InputEvent) -> void:
	if not log_remote_input:
		return
	if event is InputEventJoypadButton and event.pressed:
		print("JOY BUTTON device=%d button=%d" % [event.device, event.button_index])
	elif event is InputEventJoypadMotion and absf(event.axis_value) > 0.5:
		print("JOY MOTION device=%d axis=%d value=%.2f" % [event.device, event.axis, event.axis_value])
	elif event is InputEventKey and event.pressed and not event.echo:
		print("KEY device=%d physical_keycode=%d" % [event.device, event.physical_keycode])
