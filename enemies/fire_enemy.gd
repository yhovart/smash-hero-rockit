extends CharacterBody2D

const SPEED = 80.0
const PATROL_DISTANCE = 100.0

var direction := 1.0
var start_x := 0.0

func _ready() -> void:
	start_x = global_position.x

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	velocity.x = direction * SPEED

	if abs(global_position.x - start_x) >= PATROL_DISTANCE:
		direction *= -1.0
		$Body.scale.x = direction

	move_and_slide()

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("player") and area.name == "PuddleHitbox":
		die()

func _on_hurtbox_body_entered(body_node: Node2D) -> void:
	if body_node.is_in_group("player"):
		if "form" in body_node and body_node.form == 2:
			die()
			return
		body_node.velocity.y = -300.0

func die() -> void:
	var particles := $SizzleParticles as CPUParticles2D
	particles.emitting = true
	$Body.visible = false
	$Hurtbox.monitoring = false
	$Hurtbox.monitorable = false
	$CollisionShape2D.set_deferred("disabled", true)
	set_physics_process(false)
	await get_tree().create_timer(0.6).timeout
	queue_free()
