extends Node2D

@export var hazard_scene: PackedScene
@export var min_interval := 1.5
@export var max_interval := 3.5
@export var spawn_x_min := 200.0
@export var spawn_x_max := 950.0
@export var spawn_y := -20.0

var timer := 0.0
var next_spawn := 2.0

func _ready() -> void:
	next_spawn = randf_range(min_interval, max_interval)

func _process(delta: float) -> void:
	timer += delta
	if timer >= next_spawn:
		timer = 0.0
		next_spawn = randf_range(min_interval, max_interval)
		_spawn_hazard()

func _spawn_hazard() -> void:
	if hazard_scene == null:
		return
	var hazard: Area2D = hazard_scene.instantiate()
	hazard.position = Vector2(randf_range(spawn_x_min, spawn_x_max), spawn_y)
	var type_roll := randi() % 3
	hazard.hazard_type = type_roll
	get_parent().add_child(hazard)
