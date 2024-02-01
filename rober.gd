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
var can_damage = false

var climbing_scale = 0.0125
var walking_scale = 0.008

@export var damage = 5

func _ready():
	$AnimatedSprite3D.pixel_size = climbing_scale

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

func _on_animation_player_animation_finished(anim_name):
	can_go = true
	$AnimatedSprite3D.pixel_size = walking_scale
	$AnimatedSprite3D.play("walk")


func _on_damage_timer_timeout():
	can_damage = true


func _on_area_3d_body_entered(body):
	if body.is_in_group("player"):
		player.health_component.take_damage(damage)
