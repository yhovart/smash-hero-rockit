extends Area2D

enum HazardType { ROCK, FIREBALL, ICICLE }

var hazard_type: HazardType = HazardType.ROCK
var fall_speed := 250.0
var hit_done := false
var arm_frames := 0
var deflected := false
var horizontal_dir := 0.0
const HORIZONTAL_SPEED = 350.0
var bouncing := false
var bounce_dir := 0.0
const BOUNCE_H_SPEED = 180.0
const BOUNCE_V_SPEED = -200.0
var bounce_velocity := Vector2.ZERO
const BOUNCE_GRAVITY = 600.0

func _ready() -> void:
	monitoring = false
	match hazard_type:
		HazardType.ROCK:
			fall_speed = randf_range(200.0, 300.0)
			bounce_dir = 1.0 if randf() > 0.5 else -1.0
			$Visual.color = Color(0.5, 0.4, 0.3, 1.0)
			$Visual.polygon = PackedVector2Array([
				Vector2(0, -16), Vector2(12, -10), Vector2(16, 0),
				Vector2(12, 12), Vector2(4, 16), Vector2(-8, 14),
				Vector2(-16, 6), Vector2(-14, -8), Vector2(-6, -14)
			])
		HazardType.FIREBALL:
			fall_speed = randf_range(300.0, 400.0)
			$Visual.color = Color(1.0, 0.5, 0.0, 1.0)
			$Visual.polygon = PackedVector2Array([
				Vector2(0, -18), Vector2(10, -12), Vector2(14, 0),
				Vector2(10, 10), Vector2(0, 16), Vector2(-10, 10),
				Vector2(-14, 0), Vector2(-10, -12)
			])
			$Glow.visible = true
		HazardType.ICICLE:
			fall_speed = randf_range(350.0, 450.0)
			$Visual.color = Color(0.6, 0.85, 1.0, 0.9)
			$Visual.polygon = PackedVector2Array([
				Vector2(0, 22), Vector2(-10, -6), Vector2(-6, -18),
				Vector2(0, -22), Vector2(6, -18), Vector2(10, -6)
			])

func _physics_process(delta: float) -> void:
	arm_frames += 1
	if arm_frames == 3 and not monitoring:
		monitoring = true
	if deflected:
		position.x += horizontal_dir * HORIZONTAL_SPEED * delta
		$Visual.rotation += horizontal_dir * 10.0 * delta
		if position.x < -50.0 or position.x > 1200.0:
			queue_free()
	elif bouncing:
		bounce_velocity.y += BOUNCE_GRAVITY * delta
		position += bounce_velocity * delta
		$Visual.rotation += bounce_dir * 6.0 * delta
		if position.x < -50.0 or position.x > 1200.0:
			queue_free()
	else:
		position.y += fall_speed * delta
		if hazard_type == HazardType.FIREBALL:
			$Visual.rotation += 5.0 * delta
	if position.y > 700.0:
		queue_free()

func _on_body_entered(body_node: Node2D) -> void:
	if hit_done:
		return

	if deflected:
		if body_node.is_in_group("player") and body_node.has_method("take_hit"):
			hit_done = true
			body_node.take_hit(3, horizontal_dir)
			_explode()
		return

	if bouncing:
		if body_node.is_in_group("player") and body_node.has_method("take_hit"):
			hit_done = true
			body_node.take_hit(1, bounce_dir)
			_explode()
		elif body_node is StaticBody2D:
			bounce_velocity.y = BOUNCE_V_SPEED
			position.y -= 2.0
		return

	if body_node.is_in_group("player") and body_node.has_method("take_hit"):
		var dy := global_position.y - body_node.global_position.y
		if dy < -4.0:
			hit_done = true
			var dir: float = sign(body_node.velocity.x) if body_node.velocity.x != 0.0 else 1.0
			body_node.take_hit(1, dir * 0.3)
			_explode()
		else:
			_deflect(body_node)
		return

	if body_node is StaticBody2D and hazard_type == HazardType.ROCK:
		_start_bounce()
		return

func _start_bounce() -> void:
	bouncing = true
	bounce_velocity = Vector2(bounce_dir * BOUNCE_H_SPEED, BOUNCE_V_SPEED)
	position.y -= 2.0

func _deflect(body_node: Node2D) -> void:
	deflected = true
	var push_dir: float = sign(global_position.x - body_node.global_position.x)
	if push_dir == 0.0:
		push_dir = 1.0 if randf() > 0.5 else -1.0
	horizontal_dir = push_dir
	fall_speed = 0.0

func reflect(source: Node2D) -> void:
	if hit_done:
		return
	deflected = true
	var push_dir: float = sign(global_position.x - source.global_position.x)
	if push_dir == 0.0:
		push_dir = 1.0 if randf() > 0.5 else -1.0
	horizontal_dir = push_dir
	fall_speed = 0.0

func _explode() -> void:
	$Visual.visible = false
	if has_node("Glow"):
		$Glow.visible = false
	$Particles.emitting = true
	$CollisionShape2D.set_deferred("disabled", true)
	set_physics_process(false)
	await get_tree().create_timer(0.5).timeout
	queue_free()
