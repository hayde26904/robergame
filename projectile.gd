extends CharacterBody3D


@export var SPEED = 50
@export var DAMAGE = 5

@export var rotation_vector = Vector3.ZERO

@export var explosion_sprite = preload("res://explosionsprite.tscn")

@onready var root_node = get_tree().get_root().get_child(0)


func _physics_process(delta):
	velocity = rotation_vector * SPEED
	move_and_slide()


func _on_area_3d_body_entered(body):
	if body.has_node("HealthComponent"):
		body.get_node("HealthComponent").take_damage(DAMAGE)
		spawn_explosion(body)
		queue_free()
		
func spawn_explosion(body):
	var new_explosion = explosion_sprite.instantiate()
	var position_randomizer = randf_range(-0.25, 0.25)
	new_explosion.position = Vector3(position_randomizer, position_randomizer * 5, position_randomizer)
	body.add_child(new_explosion)


func _on_timer_timeout():
	queue_free()
