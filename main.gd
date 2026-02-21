extends Node2D

const P1_ACTIONS: Array[String] = ["p1_left", "p1_right", "p1_jump", "p1_attack", "p1_vapor", "p1_puddle"]
const P2_ACTIONS: Array[String] = ["p2_left", "p2_right", "p2_jump", "p2_attack", "p2_vapor", "p2_puddle"]
const CHARACTER_NAMES: Array[String] = ["Franck", "Yves-Henri", "Joel", "Maite"]
const CHARACTER_ASSET_PREFIXES: Array[String] = ["franck", "Yves-Henri", "Joel", "Maite"]
const ARENA_NAMES: Array[String] = ["Classic", "Sky Bridge", "Pitfall"]
const WINS_TO_TAKE_MATCH := 2
const ROUND_RESULT_MIN_DISPLAY := 2.0
const MATCH_RESULT_MIN_DISPLAY := 2.5
const CHARACTER_COLORS: Array[Color] = [
	Color(0.15, 0.45, 0.95, 1.0),
	Color(0.9, 0.2, 0.15, 1.0),
	Color(0.2, 0.8, 0.35, 1.0),
	Color(0.95, 0.75, 0.2, 1.0),
]

@export var log_remote_input := true

var is_character_select_active := true
var p1_character_index := 0
var p2_character_index := 1
var arena_select_index := 0
var p1_locked := false
var p2_locked := false
var is_arena_select_active := false
var p1_round_wins := 0
var p2_round_wins := 0
var current_round := 1
var is_round_result_active := false
var is_match_over := false
var round_result_input_delay := 0.0
var selected_arena_index := 0
var menu_asset_lookup: Dictionary = {}

@onready var player_1: Node = $Player1
@onready var player_2: Node = $Player2
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
@onready var character_select: CanvasLayer = $CharacterSelect
@onready var character_title: Label = $CharacterSelect/MenuPanel/Title
@onready var p1_choice: Label = $CharacterSelect/MenuPanel/P1Choice
@onready var p2_choice: Label = $CharacterSelect/MenuPanel/P2Choice
@onready var p1_swatch: ColorRect = $CharacterSelect/MenuPanel/P1Swatch
@onready var p2_swatch: ColorRect = $CharacterSelect/MenuPanel/P2Swatch
@onready var p1_face_preview: TextureRect = $CharacterSelect/MenuPanel/P1Swatch/Face
@onready var p2_face_preview: TextureRect = $CharacterSelect/MenuPanel/P2Swatch/Face
@onready var p1_controls: Label = $CharacterSelect/MenuPanel/P1Controls
@onready var p2_controls: Label = $CharacterSelect/MenuPanel/P2Controls
@onready var p1_arena_label: Label = $CharacterSelect/MenuPanel/P1Arena
@onready var p2_arena_label: Label = $CharacterSelect/MenuPanel/P2Arena
@onready var arena_hint: Label = $CharacterSelect/MenuPanel/ArenaHint
@onready var menu_hint: Label = $CharacterSelect/MenuPanel/Hint
@onready var arena_preview_title: Label = $CharacterSelect/MenuPanel/ArenaPreviewTitle
@onready var arena_preview_text: Label = $CharacterSelect/MenuPanel/ArenaPreviewText
@onready var arena_preview_thumb: ColorRect = $CharacterSelect/MenuPanel/ArenaPreviewThumb
@onready var arena_preview_platform_1: ColorRect = $CharacterSelect/MenuPanel/ArenaPreviewThumb/Platform1
@onready var arena_preview_platform_2: ColorRect = $CharacterSelect/MenuPanel/ArenaPreviewThumb/Platform2
@onready var arena_preview_platform_3: ColorRect = $CharacterSelect/MenuPanel/ArenaPreviewThumb/Platform3
@onready var end_screen: CanvasLayer = $EndScreen
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


func _ready() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	if player_1.has_signal("died"):
		player_1.connect("died", Callable(self, "_on_player_1_died"))
	if player_2.has_signal("died"):
		player_2.connect("died", Callable(self, "_on_player_2_died"))
	_build_menu_asset_lookup()
	end_screen.visible = false
	_initialize_character_select()
	_ensure_remote_fallback_bindings()
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	_refresh_joypad_mapping()


func _process(delta: float) -> void:
	if is_round_result_active:
		round_result_input_delay = max(round_result_input_delay - delta, 0.0)
		_handle_round_result_input()
		return
	if not is_character_select_active:
		_handle_in_fight_menu_input()
		return
	_handle_character_select_input()


func _handle_in_fight_menu_input() -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		_return_to_main_menu()


func _initialize_character_select() -> void:
	is_character_select_active = true
	is_arena_select_active = false
	p1_locked = false
	p2_locked = false
	arena_select_index = 0
	hud.visible = false
	_set_gameplay_enabled(false)
	character_select.visible = true
	_update_character_select_ui()


func _set_gameplay_enabled(enabled: bool) -> void:
	player_1.visible = enabled
	player_2.visible = enabled
	if player_1.has_method("set_physics_process"):
		player_1.set_physics_process(enabled)
	if player_2.has_method("set_physics_process"):
		player_2.set_physics_process(enabled)
	hazard_spawner.set_process(enabled)


func _handle_character_select_input() -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
		return

	if is_arena_select_active:
		_handle_arena_select_input()
		return

	var changed := false

	if not p1_locked:
		if Input.is_action_just_pressed("p1_left"):
			p1_character_index = wrapi(p1_character_index - 1, 0, CHARACTER_NAMES.size())
			changed = true
		elif Input.is_action_just_pressed("p1_right"):
			p1_character_index = wrapi(p1_character_index + 1, 0, CHARACTER_NAMES.size())
			changed = true
		if Input.is_action_just_pressed("p1_attack") or Input.is_action_just_pressed("p1_jump"):
			p1_locked = true
			changed = true
	elif Input.is_action_just_pressed("p1_jump"):
		p1_locked = false
		changed = true

	if not p2_locked:
		if Input.is_action_just_pressed("p2_left"):
			p2_character_index = wrapi(p2_character_index - 1, 0, CHARACTER_NAMES.size())
			changed = true
		elif Input.is_action_just_pressed("p2_right"):
			p2_character_index = wrapi(p2_character_index + 1, 0, CHARACTER_NAMES.size())
			changed = true
		if Input.is_action_just_pressed("p2_attack") or Input.is_action_just_pressed("p2_jump"):
			p2_locked = true
			changed = true
	elif Input.is_action_just_pressed("p2_jump"):
		p2_locked = false
		changed = true

	if changed:
		_update_character_select_ui()

	if p1_locked and p2_locked:
		_enter_arena_submenu()


func _enter_arena_submenu() -> void:
	is_arena_select_active = true
	_update_character_select_ui()


func _handle_arena_select_input() -> void:
	if _return_to_menu_pressed_any_player():
		is_arena_select_active = false
		p1_locked = false
		p2_locked = false
		_update_character_select_ui()
		return

	var changed := false
	if Input.is_action_just_pressed("p1_left") or Input.is_action_just_pressed("p2_left"):
		arena_select_index = wrapi(arena_select_index - 1, 0, ARENA_NAMES.size())
		changed = true
	elif Input.is_action_just_pressed("p1_right") or Input.is_action_just_pressed("p2_right"):
		arena_select_index = wrapi(arena_select_index + 1, 0, ARENA_NAMES.size())
		changed = true

	if changed:
		_update_character_select_ui()

	if _confirm_pressed_any_player():
		_start_match_with_selection()


func _start_match_with_selection() -> void:
	_apply_character_to_player(player_1, p1_character_index)
	_apply_character_to_player(player_2, p2_character_index)
	selected_arena_index = arena_select_index
	_apply_arena(selected_arena_index)
	character_select.visible = false
	_start_best_of_three()


func _start_best_of_three() -> void:
	p1_round_wins = 0
	p2_round_wins = 0
	current_round = 1
	is_match_over = false
	is_round_result_active = false
	end_screen.visible = false
	hud.visible = true
	is_character_select_active = false
	_reset_players_for_round()
	_set_gameplay_enabled(true)


func _reset_players_for_round() -> void:
	if player_1.has_method("reset_for_round"):
		player_1.reset_for_round()
	if player_2.has_method("reset_for_round"):
		player_2.reset_for_round()


func _on_player_1_died() -> void:
	_handle_round_end(2)


func _on_player_2_died() -> void:
	_handle_round_end(1)


func _handle_round_end(winner_player: int) -> void:
	if is_character_select_active or is_round_result_active:
		return

	is_round_result_active = true
	_set_gameplay_enabled(false)

	if winner_player == 1:
		p1_round_wins += 1
	else:
		p2_round_wins += 1

	var winner_name := "P1" if winner_player == 1 else "P2"
	var winner_color := Color(0.2, 0.5, 1.0, 0.88) if winner_player == 1 else Color(1.0, 0.2, 0.2, 0.88)

	if p1_round_wins >= WINS_TO_TAKE_MATCH or p2_round_wins >= WINS_TO_TAKE_MATCH:
		is_match_over = true
		round_result_input_delay = MATCH_RESULT_MIN_DISPLAY
		_show_end_screen("DEATH SCREEN", "%s WINS THE MATCH" % winner_name, winner_color, "Match Score %d - %d" % [p1_round_wins, p2_round_wins], "Attack/Jump: Rematch   Vapor: Main Menu")
		_update_end_screen_faces(winner_player)
	else:
		is_match_over = false
		round_result_input_delay = ROUND_RESULT_MIN_DISPLAY
		_show_end_screen("DEATH SCREEN", "%s WINS ROUND %d" % [winner_name, current_round], winner_color, "Match Score %d - %d" % [p1_round_wins, p2_round_wins], "Attack/Jump: Next Round   Vapor: Main Menu")
		_update_end_screen_faces(winner_player)


func _show_end_screen(title: String, subtitle: String, tint: Color, score_text: String, hint_text: String) -> void:
	end_screen.visible = true
	end_title.text = title
	end_subtitle.text = subtitle
	end_score.text = score_text
	end_arena.text = "Arena: %s" % ARENA_NAMES[selected_arena_index]
	end_hint.text = hint_text
	end_backdrop.color = tint


func _update_end_screen_faces(winner_player: int) -> void:
	var winner_node: Node = player_1 if winner_player == 1 else player_2
	var loser_node: Node = player_2 if winner_player == 1 else player_1

	winner_tag.text = "WINNER P%d" % winner_player
	loser_tag.text = "LOSER P%d" % (2 if winner_player == 1 else 1)

	winner_face.texture = _get_player_expression_texture(winner_node, "face")
	loser_face.texture = _get_player_expression_texture(loser_node, "dolor")

	if loser_face.texture == null:
		loser_face.texture = _get_player_expression_texture(loser_node, "face")

	winner_face.visible = winner_face.texture != null
	loser_face.visible = loser_face.texture != null


func _get_player_expression_texture(player_node: Node, expression: String) -> Texture2D:
	if player_node.has_method("get_expression_texture"):
		return player_node.get_expression_texture(expression)
	return null


func _handle_round_result_input() -> void:
	if round_result_input_delay > 0.0:
		return
	if _return_to_menu_pressed_any_player():
		_return_to_main_menu()
		return
	if not _confirm_pressed_any_player():
		return

	if is_match_over:
		_start_best_of_three()
		return

	current_round += 1
	is_round_result_active = false
	end_screen.visible = false
	_reset_players_for_round()
	_set_gameplay_enabled(true)


func _return_to_menu_pressed_any_player() -> bool:
	return Input.is_action_just_pressed("p1_vapor") \
		or Input.is_action_just_pressed("p2_vapor")


func _return_to_main_menu() -> void:
	is_round_result_active = false
	is_match_over = false
	round_result_input_delay = 0.0
	p1_round_wins = 0
	p2_round_wins = 0
	current_round = 1
	end_screen.visible = false
	_initialize_character_select()


func _confirm_pressed_any_player() -> bool:
	return Input.is_action_just_pressed("p1_attack") \
		or Input.is_action_just_pressed("p1_jump") \
		or Input.is_action_just_pressed("p2_attack") \
		or Input.is_action_just_pressed("p2_jump")


func _apply_character_to_player(player_node: Node, character_index: int) -> void:
	var color := CHARACTER_COLORS[character_index]
	var asset_prefix := CHARACTER_ASSET_PREFIXES[character_index]
	if player_node.has_method("apply_character_profile"):
		player_node.apply_character_profile(color, asset_prefix)
	elif player_node.has_method("apply_character_color"):
		player_node.apply_character_color(color)


func _update_character_select_ui() -> void:
	if is_arena_select_active:
		character_title.text = "Arena Select"
		p1_choice.text = "P1  READY"
		p2_choice.text = "READY  P2"
		p1_swatch.visible = false
		p2_swatch.visible = false
		p1_arena_label.text = "Arena: %s" % ARENA_NAMES[arena_select_index]
		p2_arena_label.text = "Shared Select"
		p1_controls.text = "Prev/Next Arena: A / D\nConfirm Arena: E or W\nBack: Shift"
		p2_controls.text = "Prev/Next Arena: J / L\nConfirm Arena: K or I\nBack: O"
		arena_hint.text = "Both players can change the same arena value"
		menu_hint.text = "Confirm: Attack/Jump • Back: Vapor • Quit: Esc"
		arena_preview_title.visible = true
		arena_preview_text.visible = true
		arena_preview_thumb.visible = true
		_update_arena_preview_ui()
		return

	character_title.text = "Character Select"
	var p1_name := _fit_menu_name(CHARACTER_NAMES[p1_character_index], 10)
	var p2_name := _fit_menu_name(CHARACTER_NAMES[p2_character_index], 10)
	p1_choice.text = "P1  %s  %s" % [p1_name, "LOCKED" if p1_locked else "READY?"]
	p2_choice.text = "%s  %s  P2" % ["LOCKED" if p2_locked else "READY?", p2_name]
	p1_swatch.visible = true
	p2_swatch.visible = true
	p1_swatch.color = Color(0.08, 0.1, 0.12, 0.95)
	p2_swatch.color = Color(0.08, 0.1, 0.12, 0.95)
	p1_face_preview.texture = _get_menu_character_texture(p1_character_index, "attack" if p1_locked else "face")
	p2_face_preview.texture = _get_menu_character_texture(p2_character_index, "attack" if p2_locked else "face")
	p1_face_preview.visible = p1_face_preview.texture != null
	p2_face_preview.visible = p2_face_preview.texture != null
	p1_arena_label.text = "Arena: %s" % ARENA_NAMES[arena_select_index]
	p2_arena_label.text = "Arena: %s" % ARENA_NAMES[arena_select_index]
	p1_controls.text = "Prev/Next Character: A / D\nLock Character: E or W\nUnlock: W"
	p2_controls.text = "Prev/Next Character: J / L\nLock Character: K or I\nUnlock: I"
	arena_hint.text = "After both characters lock, arena selection opens with preview"
	menu_hint.text = "Confirm: Attack/Jump • Unlock: Jump • Quit: Esc"
	arena_preview_title.visible = false
	arena_preview_text.visible = false
	arena_preview_thumb.visible = false


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
	var prefix := CHARACTER_ASSET_PREFIXES[character_index]
	for state in [expression, "face"]:
		var key := _normalize_asset_name("%s_%s" % [prefix, state])
		var path: String = menu_asset_lookup.get(key, "")
		if not path.is_empty():
			var texture := _try_load_menu_texture(path)
			if texture != null:
				return texture
	return null


func _try_load_menu_texture(path: String) -> Texture2D:
	if not FileAccess.file_exists(path):
		return null
	var image := Image.new()
	if image.load(path) != OK:
		return null
	var texture := ImageTexture.create_from_image(image)
	if texture != null:
		return texture
	return null


func _fit_menu_name(display_name: String, max_len: int) -> String:
	if display_name.length() <= max_len:
		return display_name
	return display_name.substr(0, max_len - 1) + "…"


func _normalize_asset_name(asset_name: String) -> String:
	return asset_name.to_lower().replace("-", "_")


func _update_arena_preview_ui() -> void:
	arena_preview_title.text = "Preview: %s" % ARENA_NAMES[arena_select_index]
	arena_preview_text.text = "Small stage thumbnail"
	arena_preview_platform_1.visible = true
	arena_preview_platform_2.visible = true
	arena_preview_platform_3.visible = true

	match arena_select_index:
		0:
			arena_preview_platform_1.position = Vector2(18, 70)
			arena_preview_platform_2.position = Vector2(96, 52)
			arena_preview_platform_3.position = Vector2(40, 34)
		1:
			arena_preview_platform_1.position = Vector2(12, 74)
			arena_preview_platform_2.position = Vector2(70, 58)
			arena_preview_platform_3.position = Vector2(126, 42)
		2:
			arena_preview_platform_1.position = Vector2(12, 74)
			arena_preview_platform_2.position = Vector2(70, 74)
			arena_preview_platform_3.position = Vector2(126, 74)
			arena_preview_platform_2.visible = false


func _apply_arena(arena_index: int) -> void:
	_set_platform_enabled(platform_1, platform_1_shape, platform_1_visual, true)
	_set_platform_enabled(platform_2, platform_2_shape, platform_2_visual, true)
	_set_platform_enabled(platform_3, platform_3_shape, platform_3_visual, true)

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
			platform_2.position = Vector2(576, 360)
			platform_3.position = Vector2(832, 500)
			_set_platform_enabled(platform_2, platform_2_shape, platform_2_visual, false)


func _set_platform_enabled(platform_node: Node2D, platform_shape: CollisionShape2D, platform_visual: CanvasItem, enabled: bool) -> void:
	platform_node.visible = enabled
	platform_shape.disabled = not enabled
	if platform_visual != null:
		platform_visual.visible = enabled


func _on_joy_connection_changed(_device: int, _connected: bool) -> void:
	_refresh_joypad_mapping()


func _refresh_joypad_mapping() -> void:
	var connected := Input.get_connected_joypads()
	if connected.is_empty():
		print("No joypads detected by Godot. If this is a TV remote, it may be exposing keyboard events instead.")
		_print_wsl_input_hint()
		_print_snap_joystick_hint()
		return

	var names: PackedStringArray = []
	for joy_id in connected:
		names.append("%d:%s" % [joy_id, Input.get_joy_name(joy_id)])
	print("Connected joypads -> ", ", ".join(names))

	var p1_device: int = connected[0]
	_assign_actions_to_device(P1_ACTIONS, p1_device)

	if connected.size() > 1:
		var p2_device: int = connected[1]
		_assign_actions_to_device(P2_ACTIONS, p2_device)
		print("Mapped P1 to device %d, P2 to device %d" % [p1_device, p2_device])
	else:
		_strip_joypad_events(P2_ACTIONS)
		print("Mapped P1 to device %d, P2 keyboard only (single gamepad)" % p1_device)


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
	print("WSL detected. /dev/input is typically unavailable, so joypads/remotes may not be visible to Linux apps.")
	print("Use native Windows Godot for controller input, or pass through a USB receiver with usbipd.")


func _assign_actions_to_device(actions: Array[String], device: int) -> void:
	for action in actions:
		var events := InputMap.action_get_events(action)
		var rebuilt_events: Array[InputEvent] = []

		for event in events:
			if event is InputEventJoypadButton or event is InputEventJoypadMotion:
				var new_event := event.duplicate()
				new_event.device = device
				rebuilt_events.append(new_event)
			else:
				rebuilt_events.append(event)

		InputMap.action_erase_events(action)
		for input_event in rebuilt_events:
			InputMap.action_add_event(action, input_event)


func _strip_joypad_events(actions: Array[String]) -> void:
	for action in actions:
		var events := InputMap.action_get_events(action)
		InputMap.action_erase_events(action)
		for event in events:
			if not (event is InputEventJoypadButton or event is InputEventJoypadMotion):
				InputMap.action_add_event(action, event)


func _ensure_remote_fallback_bindings() -> void:
	_bind_key_if_missing("p1_left", KEY_LEFT)
	_bind_key_if_missing("p1_right", KEY_RIGHT)
	_bind_key_if_missing("p1_jump", KEY_UP)
	_bind_key_if_missing("p1_jump", KEY_SPACE)
	_bind_key_if_missing("p1_attack", KEY_ENTER)
	_bind_key_if_missing("p1_attack", KEY_KP_ENTER)
	_bind_key_if_missing("p1_vapor", KEY_BACKSPACE)
	_bind_key_if_missing("p1_puddle", KEY_DOWN)

	_bind_joy_button_if_missing("p1_left", JOY_BUTTON_DPAD_LEFT, 0)
	_bind_joy_button_if_missing("p1_right", JOY_BUTTON_DPAD_RIGHT, 0)
	_bind_joy_button_if_missing("p1_jump", JOY_BUTTON_A, 0)
	_bind_joy_button_if_missing("p1_attack", JOY_BUTTON_X, 0)
	_bind_joy_button_if_missing("p1_vapor", JOY_BUTTON_Y, 0)
	_bind_joy_button_if_missing("p1_puddle", JOY_BUTTON_B, 0)
	_bind_joy_motion_if_missing("p1_left", JOY_AXIS_LEFT_X, -1.0, 0)
	_bind_joy_motion_if_missing("p1_right", JOY_AXIS_LEFT_X, 1.0, 0)


func _bind_key_if_missing(action: String, keycode: Key) -> void:
	for event in InputMap.action_get_events(action):
		if event is InputEventKey and event.keycode == keycode:
			return
	var key_event := InputEventKey.new()
	key_event.keycode = keycode
	InputMap.action_add_event(action, key_event)


func _bind_joy_button_if_missing(action: String, button: JoyButton, device: int) -> void:
	for event in InputMap.action_get_events(action):
		if event is InputEventJoypadButton and event.button_index == button and event.device == device:
			return
	var button_event := InputEventJoypadButton.new()
	button_event.button_index = button
	button_event.device = device
	InputMap.action_add_event(action, button_event)


func _bind_joy_motion_if_missing(action: String, axis: JoyAxis, axis_value: float, device: int) -> void:
	for event in InputMap.action_get_events(action):
		if event is InputEventJoypadMotion and event.axis == axis and is_equal_approx(event.axis_value, axis_value) and event.device == device:
			return
	var motion_event := InputEventJoypadMotion.new()
	motion_event.axis = axis
	motion_event.axis_value = axis_value
	motion_event.device = device
	InputMap.action_add_event(action, motion_event)


func _unhandled_input(event: InputEvent) -> void:
	if not log_remote_input:
		return
	if event is InputEventJoypadButton and event.pressed:
		print("JOY BUTTON device=%d button=%d" % [event.device, event.button_index])
	elif event is InputEventJoypadMotion and absf(event.axis_value) > 0.5:
		print("JOY MOTION device=%d axis=%d value=%.2f" % [event.device, event.axis, event.axis_value])
	elif event is InputEventKey and event.pressed and not event.echo:
		print("KEY device=%d physical_keycode=%d" % [event.device, event.physical_keycode])
