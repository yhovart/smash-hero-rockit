extends Area2D

enum HazardType { ROCK, FIREBALL, ICICLE }

var hazard_type: HazardType = HazardType.ROCK
var fall_speed := 250.0
var hit_done := false
var arm_frames := 0

func _ready() -> void:
	monitoring = false
	match hazard_type:
		HazardType.ROCK:
			fall_speed = randf_range(200.0, 300.0)
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
	position.y += fall_speed * delta
	if hazard_type == HazardType.FIREBALL:
		$Visual.rotation += 5.0 * delta
	if position.y > 700.0:
		queue_free()

func _on_body_entered(body_node: Node2D) -> void:
	if hit_done:
		return
	if body_node.is_in_group("player") and body_node.has_method("take_hit"):
		hit_done = true
		var dir: float = sign(body_node.velocity.x) if body_node.velocity.x != 0.0 else 1.0
		body_node.take_hit(1, dir * 0.3)
		_explode()
	elif not body_node.is_in_group("player"):
		hit_done = true
		_explode()

func _explode() -> void:
	$Visual.visible = false
	if has_node("Glow"):
		$Glow.visible = false
	$Particles.emitting = true
	$CollisionShape2D.set_deferred("disabled", true)
	set_physics_process(false)
	await get_tree().create_timer(0.5).timeout
	queue_free()
