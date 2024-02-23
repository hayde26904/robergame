extends CharacterBody3D


@export var SPEED = 300
@export var DAMAGE = 5

@export var direction = Vector3.ZERO

@export var explosion_sprite = preload("res://explosionsprite.tscn")

@onready var root_node = get_tree().get_root().get_child(0)


func _physics_process(delta):
	velocity = direction * SPEED
	move_and_slide()


func _on_area_3d_body_entered(body):
	if body.has_node("HealthComponent"):
		body.get_node("HealthComponent").take_damage(DAMAGE)
		if body.is_in_group("rober"):
			body.make_damage_particle(position, 1)
		queue_free()


func _on_timer_timeout():
	queue_free()
