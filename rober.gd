extends CharacterBody3D


var SPEED = randi_range(5,10)
const JUMP_VELOCITY = 8

var direction = Vector3.ZERO;

@onready var root_node = get_tree().get_root().get_child(0)
@onready var player = root_node.get_node("Player")
@onready var health_component = %HealthComponent
@onready var ray_cast = %RayCast3D
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var damage_particle : PackedScene = preload("res://explosionsprite.tscn")

var out_of_ground = false
var can_damage = false

var climbing_scale = 0.0125
var walking_scale = 0.008

@export var damage = 2

var player_when_touching = null

func _ready():
	pass

func _physics_process(delta):
	
	look_at(player.position, Vector3.UP)
	rotation.x = 0
	
	if out_of_ground:
		# Add the gravity.
		if not is_on_floor():
			velocity.y -= gravity * delta
		
		direction = -Vector3(sin(rotation.y),0, cos(rotation.y))
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	
		if health_component.health <= 0:
			die()
			
		if player_when_touching != null and can_damage:
			player_when_touching.health_component.take_damage(damage)
			can_damage = false
		
		move_and_slide()

func die():
	make_damage_particle(Vector3(position.x, 3, position.z), 8)
	queue_free()

func make_damage_particle(pos : Vector3, p_size : float):
	var new_explosion = damage_particle.instantiate()
	new_explosion.position = pos
	if p_size != -1:
		new_explosion.pixel_size = p_size / 100
	root_node.add_child(new_explosion)

func _on_animation_player_animation_finished(anim_name):
	out_of_ground = true
	#$AnimatedSprite3D.pixel_size = walking_scale
	#$AnimatedSprite3D.play("walk")


func _on_damage_timer_timeout():
	can_damage = true

func _on_jump_timer_timeout():
	if ray_cast.is_colliding() and is_on_floor():
		velocity.y = JUMP_VELOCITY

func _on_area_3d_body_entered(body):
	if body.is_in_group("player"):
		player_when_touching = body
		

func _on_area_3d_body_exited(body):
	if body.is_in_group("player"):
		player_when_touching = null
