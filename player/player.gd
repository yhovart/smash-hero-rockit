extends CharacterBody2D

enum Form { WATER, VAPOR, PUDDLE }

const SPEED = 300.0
const JUMP_VELOCITY = -550.0
const VAPOR_SPEED = 120.0
const VAPOR_FLOAT = -80.0
const VAPOR_MAX_TIME = 3.0
const PUDDLE_SPEED = 150.0
const PUDDLE_MAX_TIME = 3.0
const FORM_COOLDOWN = 2.0

var form: Form = Form.WATER
var form_timer := 0.0
var cooldown_timer := 0.0

@onready var body: Polygon2D = $Body
@onready var shine: Polygon2D = $Shine
@onready var vapor_particles: CPUParticles2D = $VaporParticles
@onready var puddle_body: Polygon2D = $PuddleBody
@onready var puddle_hitbox: Area2D = $PuddleHitbox
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _physics_process(delta: float) -> void:
	cooldown_timer = max(cooldown_timer - delta, 0.0)

	if cooldown_timer <= 0.0:
		if Input.is_action_just_pressed("vapor") and form == Form.WATER:
			_enter_vapor()
		elif Input.is_action_just_released("vapor") and form == Form.VAPOR:
			_exit_form()
		elif Input.is_action_just_pressed("puddle") and form == Form.WATER and is_on_floor():
			_enter_puddle()
		elif Input.is_action_just_released("puddle") and form == Form.PUDDLE:
			_exit_form()

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

	move_and_slide()

func _normal_physics(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

func _vapor_physics(_delta: float) -> void:
	velocity.y = VAPOR_FLOAT

	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * VAPOR_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, VAPOR_SPEED)

func _puddle_physics(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * PUDDLE_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, PUDDLE_SPEED)

func _enter_vapor() -> void:
	form = Form.VAPOR
	form_timer = VAPOR_MAX_TIME
	body.modulate = Color(0.6, 0.8, 1.0, 0.35)
	shine.modulate = Color(1.0, 1.0, 1.0, 0.2)
	vapor_particles.emitting = true
	puddle_body.visible = false
	puddle_hitbox.monitoring = false
	scale = Vector2(1.3, 0.8)

func _enter_puddle() -> void:
	form = Form.PUDDLE
	form_timer = PUDDLE_MAX_TIME
	body.visible = false
	shine.visible = false
	puddle_body.visible = true
	puddle_hitbox.monitoring = true
	collision_shape.position = Vector2(0, 14)
	collision_shape.shape.radius = 6.0
	scale = Vector2(1.0, 1.0)

func _exit_form() -> void:
	var was_puddle := form == Form.PUDDLE
	form = Form.WATER
	cooldown_timer = FORM_COOLDOWN

	body.visible = true
	body.modulate = Color(1.0, 1.0, 1.0, 1.0)
	shine.visible = true
	shine.modulate = Color(1.0, 1.0, 1.0, 1.0)
	vapor_particles.emitting = false
	puddle_body.visible = false
	puddle_hitbox.monitoring = false
	scale = Vector2(1.0, 1.0)

	if was_puddle:
		collision_shape.position = Vector2(0, 4)
		collision_shape.shape.radius = 14.0
