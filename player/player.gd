extends CharacterBody2D

enum Form { WATER, VAPOR, PUDDLE }

const SPEED = 300.0
const ACCELERATION = 3200.0
const DECELERATION = 4000.0
const AIR_ACCELERATION = 2400.0
const AIR_DECELERATION = 1400.0
const JUMP_VELOCITY = -480.0
const FALL_GRAVITY_MULT = 2.5
const LOW_JUMP_GRAVITY_MULT = 4.5
const COYOTE_TIME = 0.1
const JUMP_BUFFER_TIME = 0.12
const DOUBLE_JUMP_VELOCITY = -420.0
const FAST_FALL_SPEED = 900.0
const VAPOR_SPEED = 120.0
const VAPOR_FLOAT = -80.0
const VAPOR_MAX_TIME = 3.0
const PUDDLE_SPEED = 150.0
const PUDDLE_MAX_TIME = 3.0
const FORM_COOLDOWN = 2.0
const ATTACK_KNOCKBACK = 800.0
const MAX_HITS = 3
const MAX_STOCKS = 3
const HIT_INVINCIBILITY = 0.5

@export var action_left := "p1_left"
@export var action_right := "p1_right"
@export var action_jump := "p1_jump"
@export var action_attack := "p1_attack"
@export var action_vapor := "p1_vapor"
@export var action_puddle := "p1_puddle"
@export var body_color := Color(0.15, 0.45, 0.95, 1.0)
@export var spawn_position := Vector2(300, 500)
@export var asset_prefix := "franck"

var projectile_scene: PackedScene = preload("res://player/water_projectile.tscn")

var form: Form = Form.WATER
var form_timer := 0.0
var cooldown_timer := 0.0
var hits_taken := 0
var invincible_timer := 0.0
var is_attacking := false
var attack_timer := 0.0
var facing := 1.0
var charge_time := 0.0
var is_charging := false
const CHARGE_THRESHOLD = 0.4
const PROJECTILE_COOLDOWN = 0.8
var projectile_cooldown_timer := 0.0
var puddle_buffer := 0.0
const PUDDLE_BUFFER_TIME = 0.2
var drop_through_timer := 0.0
const DROP_THROUGH_TIME = 0.25
var coyote_timer := 0.0
var jump_buffer_timer := 0.0
var was_on_floor := false
var has_double_jump := true
var is_fast_falling := false
const VISUAL_STATES := ["face", "left", "right", "attack", "dolor"]
var visual_textures: Dictionary = {}

signal hit_changed(hits: int)
signal died
signal stock_changed(stocks: int)
signal eliminated

var stocks := MAX_STOCKS

@onready var body: Polygon2D = $Body
@onready var shine: Polygon2D = $Shine
@onready var avatar: Sprite2D = $Avatar
@onready var vapor_particles: CPUParticles2D = $VaporParticles
@onready var puddle_body: Polygon2D = $PuddleBody
@onready var puddle_hitbox: Area2D = $PuddleHitbox
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var attack_hitbox: Area2D = $AttackHitbox

func _ready() -> void:
	body.color = body_color
	_load_visual_textures()
	var has_avatar := visual_textures.has("face")
	avatar.visible = has_avatar
	body.visible = not has_avatar
	shine.visible = not has_avatar
	_update_avatar_texture("face")
	hit_changed.emit.call_deferred(hits_taken)
	stock_changed.emit.call_deferred(stocks)


func apply_character_color(new_color: Color) -> void:
	body_color = new_color
	if body != null:
		body.color = body_color

func apply_character_profile(new_color: Color, new_asset_prefix: String) -> void:
	apply_character_color(new_color)
	asset_prefix = new_asset_prefix
	_load_visual_textures()
	var has_avatar := visual_textures.has("face")
	avatar.visible = has_avatar and form != Form.PUDDLE
	body.visible = not has_avatar and form != Form.PUDDLE
	shine.visible = not has_avatar and form != Form.PUDDLE
	_update_visual_state()


func reset_for_round() -> void:
	stocks = MAX_STOCKS
	hits_taken = 0
	visible = true
	set_physics_process(true)
	hit_changed.emit(hits_taken)
	stock_changed.emit(stocks)
	_reset_to_spawn()

func _physics_process(delta: float) -> void:
	cooldown_timer = max(cooldown_timer - delta, 0.0)
	invincible_timer = max(invincible_timer - delta, 0.0)
	projectile_cooldown_timer = max(projectile_cooldown_timer - delta, 0.0)

	if drop_through_timer > 0.0:
		drop_through_timer -= delta
		if drop_through_timer <= 0.0:
			set_collision_mask_value(1, true)

	if invincible_timer > 0.0:
		avatar.modulate.a = 0.5 if fmod(invincible_timer, 0.15) > 0.075 else 1.0
	elif form == Form.WATER:
		avatar.modulate.a = 1.0

	_handle_attack(delta)
	_handle_form_switch(delta)

	if form != Form.WATER:
		form_timer -= delta
		if form_timer <= 0.0:
			_exit_form()

	match form:
		Form.WATER:
			_normal_physics(delta)
		Form.VAPOR:
			_vapor_physics(delta)
		Form.PUDDLE:
			_puddle_physics(delta)

	_update_visual_state()

	move_and_slide()

	if global_position.y > 700.0:
		_fall_death()

func _fall_death() -> void:
	_lose_stock()

func _lose_stock() -> void:
	stocks -= 1
	stock_changed.emit(stocks)
	died.emit()
	hits_taken = 0
	hit_changed.emit(hits_taken)
	if stocks <= 0:
		eliminated.emit()
		set_physics_process(false)
		visible = false
		return
	_reset_to_spawn()

func _reset_to_spawn() -> void:
	if form != Form.WATER:
		_exit_form()
	is_charging = false
	$ChargeVisual.visible = false
	charge_time = 0.0
	drop_through_timer = 0.0
	coyote_timer = 0.0
	jump_buffer_timer = 0.0
	has_double_jump = true
	is_fast_falling = false
	set_collision_mask_value(1, true)
	invincible_timer = HIT_INVINCIBILITY
	global_position = spawn_position
	velocity = Vector2.ZERO

func _handle_form_switch(delta: float) -> void:
	if puddle_buffer > 0.0:
		puddle_buffer -= delta

	if Input.is_action_just_pressed(action_puddle):
		puddle_buffer = PUDDLE_BUFFER_TIME

	if form == Form.VAPOR:
		if Input.is_action_just_released(action_vapor):
			_exit_form()
		return

	if form == Form.PUDDLE:
		if Input.is_action_just_released(action_puddle) or not Input.is_action_pressed(action_puddle):
			_exit_form()
		return

	if cooldown_timer > 0.0:
		return

	if Input.is_action_just_pressed(action_vapor):
		_enter_vapor()
		return

	if puddle_buffer > 0.0 and is_on_floor():
		puddle_buffer = 0.0
		_enter_puddle()

func _handle_attack(delta: float) -> void:
	if attack_timer > 0.0:
		attack_timer -= delta
		if attack_timer <= 0.0:
			is_attacking = false
			attack_hitbox.monitoring = false
			$AttackVisual.visible = false
		return

	if is_charging:
		if Input.is_action_pressed(action_attack):
			charge_time += delta
			$ChargeVisual.visible = true
			$ChargeVisual.position.x = facing * 16.0
			var charge_ratio := clampf(charge_time / CHARGE_THRESHOLD, 0.0, 1.0)
			$ChargeVisual.scale = Vector2.ONE * (0.5 + charge_ratio * 0.8)
			$ChargeVisual.modulate.a = 0.4 + charge_ratio * 0.6
		else:
			is_charging = false
			$ChargeVisual.visible = false
			if charge_time >= CHARGE_THRESHOLD and projectile_cooldown_timer <= 0.0:
				_fire_projectile()
			else:
				_melee_attack()
			charge_time = 0.0
		return

	if Input.is_action_just_pressed(action_attack) and form == Form.WATER:
		is_charging = true
		charge_time = 0.0

func _melee_attack() -> void:
	is_attacking = true
	attack_timer = 0.5
	attack_hitbox.monitoring = true
	attack_hitbox.position.x = facing * 20.0
	$AttackVisual.visible = true
	$AttackVisual.position.x = facing * 20.0
	$AttackVisual.scale.x = facing

func _fire_projectile() -> void:
	projectile_cooldown_timer = PROJECTILE_COOLDOWN
	var proj: Area2D = projectile_scene.instantiate()
	proj.direction = facing
	proj.owner_node = self
	proj.global_position = global_position + Vector2(facing * 20.0, 0)
	var c := body_color.lightened(0.3)
	proj.get_node("Visual").color = Color(c.r, c.g, c.b, 0.9)
	proj.get_node("Trail").color = Color(c.r, c.g, c.b, 0.4)
	proj.get_node("Particles").color = Color(c.r, c.g, c.b, 0.6)
	get_parent().add_child(proj)

func _normal_physics(delta: float) -> void:
	var on_floor := is_on_floor()

	if on_floor:
		coyote_timer = COYOTE_TIME
		has_double_jump = true
		is_fast_falling = false
	else:
		coyote_timer = max(coyote_timer - delta, 0.0)

	if Input.is_action_just_pressed(action_jump):
		jump_buffer_timer = JUMP_BUFFER_TIME
	else:
		jump_buffer_timer = max(jump_buffer_timer - delta, 0.0)

	if not on_floor:
		var grav := get_gravity()
		if is_fast_falling:
			velocity.y = FAST_FALL_SPEED
		elif velocity.y > 0.0:
			velocity += grav * FALL_GRAVITY_MULT * delta
		elif not Input.is_action_pressed(action_jump):
			velocity += grav * LOW_JUMP_GRAVITY_MULT * delta
		else:
			velocity += grav * delta

	if Input.is_action_just_pressed(action_puddle) and not on_floor and velocity.y >= 0.0:
		is_fast_falling = true

	var can_jump := coyote_timer > 0.0
	if jump_buffer_timer > 0.0 and can_jump:
		velocity.y = JUMP_VELOCITY
		jump_buffer_timer = 0.0
		coyote_timer = 0.0
		is_fast_falling = false
	elif jump_buffer_timer > 0.0 and not can_jump and has_double_jump:
		velocity.y = DOUBLE_JUMP_VELOCITY
		jump_buffer_timer = 0.0
		has_double_jump = false
		is_fast_falling = false

	var direction := Input.get_axis(action_left, action_right)
	var accel: float
	if on_floor:
		accel = ACCELERATION if direction else DECELERATION
	else:
		accel = AIR_ACCELERATION if direction else AIR_DECELERATION
	if direction:
		velocity.x = move_toward(velocity.x, direction * SPEED, accel * delta)
		facing = sign(direction)
	else:
		velocity.x = move_toward(velocity.x, 0.0, accel * delta)

func _vapor_physics(_delta: float) -> void:
	velocity.y = VAPOR_FLOAT
	var direction := Input.get_axis(action_left, action_right)
	if direction:
		velocity.x = direction * VAPOR_SPEED
		facing = sign(direction)
	else:
		velocity.x = move_toward(velocity.x, 0, VAPOR_SPEED)

func _puddle_physics(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed(action_jump) and is_on_floor():
		var on_platform := false
		for i in get_slide_collision_count():
			var col := get_slide_collision(i)
			if col.get_collider().is_in_group("platform"):
				on_platform = true
				break
		if on_platform:
			set_collision_mask_value(1, false)
			drop_through_timer = DROP_THROUGH_TIME
			velocity.y = 20.0

	var direction := Input.get_axis(action_left, action_right)
	if direction:
		velocity.x = direction * PUDDLE_SPEED
		facing = sign(direction)
	else:
		velocity.x = move_toward(velocity.x, 0, PUDDLE_SPEED)

func _enter_vapor() -> void:
	form = Form.VAPOR
	form_timer = VAPOR_MAX_TIME
	avatar.visible = true
	avatar.modulate = Color(1.0, 1.0, 1.0, 0.35)
	vapor_particles.emitting = true
	puddle_body.visible = false
	puddle_hitbox.monitoring = false
	scale = Vector2(1.3, 0.8)

func _enter_puddle() -> void:
	form = Form.PUDDLE
	form_timer = PUDDLE_MAX_TIME
	avatar.visible = false
	puddle_body.visible = true
	puddle_hitbox.monitoring = true
	collision_shape.position = Vector2(0, 17)
	collision_shape.shape.radius = 4.0
	scale = Vector2(1.0, 1.0)

func _exit_form() -> void:
	var was_puddle := form == Form.PUDDLE
	form = Form.WATER
	cooldown_timer = FORM_COOLDOWN
	if drop_through_timer > 0.0:
		drop_through_timer = 0.0
		set_collision_mask_value(1, true)
	body.visible = false
	shine.visible = false
	avatar.visible = true
	avatar.modulate = Color(1.0, 1.0, 1.0, 1.0)
	vapor_particles.emitting = false
	puddle_body.visible = false
	puddle_hitbox.monitoring = false
	scale = Vector2(1.0, 1.0)
	if was_puddle:
		collision_shape.position = Vector2(0, 4)
		collision_shape.shape.radius = 14.0

func take_hit(_damage: int, knockback_dir: float) -> void:
	if invincible_timer > 0.0 or form == Form.VAPOR:
		return
	hits_taken += 1
	invincible_timer = HIT_INVINCIBILITY
	velocity.x = knockback_dir * ATTACK_KNOCKBACK
	velocity.y = -200.0
	hit_changed.emit(hits_taken)
	if hits_taken >= MAX_HITS:
		_lose_stock()

func _on_attack_hitbox_area_entered(area: Area2D) -> void:
	if not area.has_method("reflect"):
		return
	if "owner_node" in area and area.owner_node == self:
		return
	area.reflect(self)
	if area.has_node("Trail"):
		var c := body_color.lightened(0.3)
		area.get_node("Visual").color = Color(c.r, c.g, c.b, 0.9)
		area.get_node("Trail").color = Color(c.r, c.g, c.b, 0.4)

func _on_attack_hitbox_body_entered(other: Node2D) -> void:
	if other == self or not other.is_in_group("player"):
		return
	if other.has_method("take_hit"):
		var dir: float = sign(other.global_position.x - global_position.x)
		if dir == 0.0:
			dir = facing
		other.take_hit(1, dir)

func _load_visual_textures() -> void:
	visual_textures.clear()
	var dir := DirAccess.open("res://assets")
	if dir == null:
		return
	var by_name: Dictionary = {}
	for file_name in dir.get_files():
		var ext := file_name.get_extension().to_lower()
		if ext not in ["png", "jpg", "jpeg", "webp"]:
			continue
		var normalized := _normalize_asset_name(file_name.get_basename())
		by_name[normalized] = "res://assets/%s" % file_name
	for state in VISUAL_STATES:
		var state_name: String = state
		if state == "right":
			state_name = "rigth"
		var key := _normalize_asset_name("%s_%s" % [asset_prefix, state])
		var typo_key := _normalize_asset_name("%s_%s" % [asset_prefix, state_name])
		var path: String = by_name.get(key, by_name.get(typo_key, ""))
		if not path.is_empty():
			var texture := _load_texture_from_path(path)
			if texture != null:
				visual_textures[state] = texture

func _update_avatar_texture(state: String) -> void:
	var tex: Texture2D = visual_textures.get(state, visual_textures.get("face", null))
	if tex != null:
		avatar.texture = tex


func get_expression_texture(state: String) -> Texture2D:
	return visual_textures.get(state, visual_textures.get("face", null))

func _update_visual_state() -> void:
	if form == Form.PUDDLE:
		return
	if invincible_timer > 0.0:
		_update_avatar_texture("dolor")
	elif is_attacking or is_charging:
		_update_avatar_texture("attack")
	elif absf(velocity.x) > 5.0:
		_update_avatar_texture("right" if facing >= 0.0 else "left")
	else:
		_update_avatar_texture("face")

func _normalize_asset_name(asset_name: String) -> String:
	return asset_name.to_lower().replace("-", "_")

func _load_texture_from_path(path: String) -> Texture2D:
	var image := Image.new()
	var err := image.load(path)
	if err != OK:
		return null
	return ImageTexture.create_from_image(image)
