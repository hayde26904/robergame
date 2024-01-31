extends CharacterBody3D


var SPEED = randi_range(5,10)
const JUMP_VELOCITY = 4.5

var direction = Vector3.ZERO;

@onready var root_node = get_tree().get_root().get_child(0)
@onready var player = root_node.get_node("Player")
@onready var health_component = %HealthComponent
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var explosion_sprite = preload("res://explosionsprite.tscn")

var can_go = false


func _physics_process(delta):
	if can_go:
		# Add the gravity.
		if not is_on_floor():
			velocity.y -= gravity * delta

		direction = Vector3(player.position.x - position.x, velocity.y, player.position.z - position.z)
		velocity = direction.normalized() * SPEED
	
		if health_component.health <= 0:
			die()
	
		move_and_slide()

func die():
	var new_explosion = explosion_sprite.instantiate()
	new_explosion.position = Vector3(position.x, 3, position.z)
	root_node.add_child(new_explosion)
	new_explosion.pixel_size = 0.08
	queue_free()

func _on_timer_timeout():
	#$Sprite3D.flip_h = not $Sprite3D.flip_h
	pass


func _on_animation_player_animation_finished(anim_name):
	can_go = true
