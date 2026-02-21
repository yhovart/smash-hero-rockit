extends Area2D

const SPEED = 450.0
const LIFETIME = 1.5

var direction := 1.0
var owner_node: Node2D = null
var timer := 0.0

func _physics_process(delta: float) -> void:
	position.x += direction * SPEED * delta
	timer += delta
	$Visual.rotation += direction * 8.0 * delta
	if timer >= LIFETIME:
		queue_free()

func _on_body_entered(hit_body: Node2D) -> void:
	if hit_body == owner_node:
		return
	if hit_body.is_in_group("player") and hit_body.has_method("take_hit"):
		hit_body.take_hit(1, direction)
	_splash()

func _splash() -> void:
	$Visual.visible = false
	$Particles.emitting = true
	$CollisionShape2D.set_deferred("disabled", true)
	set_physics_process(false)
	await get_tree().create_timer(0.4).timeout
	queue_free()
