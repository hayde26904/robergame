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

@export var damage = 2

var player_when_touching = null

func _ready():
	pass

func _physics_process(delta):
	if can_go:
		# Add the gravity.
		if not is_on_floor():
			velocity.y -= gravity * delta

		direction = Vector3(player.position.x - position.x, velocity.y, player.position.z - position.z)
		velocity = direction.normalized() * SPEED
	
		if health_component.health <= 0:
			die()
			
		if player_when_touching != null and can_damage:
			player_when_touching.health_component.take_damage(damage)
			can_damage = false
		
		move_and_slide()

func take_damage(dmg):
	var position_randomizer = Vector3(randf_range(-0.5, 0.5), randf_range(-1, 2), randf_range(-0.5,0.5))
	health_component.take_damage(dmg)

func die():
	make_explosion(Vector3(position.x, 3, position.z), 0.08)
	queue_free()

func make_explosion(pos, p_size):
	var new_explosion = explosion_sprite.instantiate()
	new_explosion.position = pos
	if p_size != -1:
		new_explosion.pixel_size = p_size
	root_node.add_child(new_explosion)

func _on_animation_player_animation_finished(anim_name):
	can_go = true
	#$AnimatedSprite3D.pixel_size = walking_scale
	#$AnimatedSprite3D.play("walk")


func _on_damage_timer_timeout():
	can_damage = true


func _on_area_3d_body_entered(body):
	if body.is_in_group("player"):
		player_when_touching = body
		

func _on_area_3d_body_exited(body):
	if body.is_in_group("player"):
		player_when_touching = null
