extends Node2D

const P1_ACTIONS: Array[String] = ["p1_left", "p1_right", "p1_jump", "p1_attack", "p1_vapor", "p1_puddle"]
const P2_ACTIONS: Array[String] = ["p2_left", "p2_right", "p2_jump", "p2_attack", "p2_vapor", "p2_puddle"]

@export var log_remote_input := true


func _ready() -> void:
	_ensure_remote_fallback_bindings()
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	_refresh_joypad_mapping()


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
	var p2_device: int = connected[1] if connected.size() > 1 else connected[0]

	_assign_actions_to_device(P1_ACTIONS, p1_device)
	_assign_actions_to_device(P2_ACTIONS, p2_device)

	print("Mapped P1 to device %d, P2 to device %d" % [p1_device, p2_device])


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


func _ensure_remote_fallback_bindings() -> void:
	_bind_key_if_missing("p1_left", KEY_LEFT)
	_bind_key_if_missing("p1_right", KEY_RIGHT)
	_bind_key_if_missing("p1_jump", KEY_UP)
	_bind_key_if_missing("p1_jump", KEY_SPACE)
	_bind_key_if_missing("p1_attack", KEY_ENTER)
	_bind_key_if_missing("p1_attack", KEY_KP_ENTER)
	_bind_key_if_missing("p1_vapor", KEY_BACKSPACE)
	_bind_key_if_missing("p1_puddle", KEY_DOWN)

	_bind_joy_button_if_missing("p1_left", JOY_BUTTON_DPAD_LEFT, -1)
	_bind_joy_button_if_missing("p1_right", JOY_BUTTON_DPAD_RIGHT, -1)
	_bind_joy_button_if_missing("p1_jump", JOY_BUTTON_A, -1)
	_bind_joy_button_if_missing("p1_attack", JOY_BUTTON_X, -1)
	_bind_joy_button_if_missing("p1_vapor", JOY_BUTTON_Y, -1)
	_bind_joy_button_if_missing("p1_puddle", JOY_BUTTON_B, -1)
	_bind_joy_motion_if_missing("p1_left", JOY_AXIS_LEFT_X, -1.0, -1)
	_bind_joy_motion_if_missing("p1_right", JOY_AXIS_LEFT_X, 1.0, -1)


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