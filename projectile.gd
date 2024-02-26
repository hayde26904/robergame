extends CharacterBody3D


@export var SPEED : int = 100
@export var DAMAGE : int = 20

@export var collision_only : bool = false

@export var direction = Vector3.ZERO

@onready var root_node = get_tree().get_root().get_child(0)
@onready var mesh = %MeshInstance3D

func _ready():
	if collision_only:
		mesh.visible = false

func _physics_process(delta):
	velocity = direction * SPEED
	move_and_slide()


func _on_area_3d_body_entered(body):
	if collision_only:
		if body.has_node("HealthComponent"):
			body.get_node("HealthComponent").take_damage(DAMAGE)
			if body.is_in_group("rober"):
				body.make_damage_particle(position, 1)
			queue_free()


func _on_timer_timeout():
	queue_free()
