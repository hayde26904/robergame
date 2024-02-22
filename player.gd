extends CharacterBody3D

const SPEED = 20
const ACCEL = 0.5
const DECEL = 0.5
const JUMP_VELOCITY = 7

const VIEW_TILT = 0.05
const IDLE_FOV = 75
const MOVING_FOV = 85

const MOUSE_SENS = 0.008

@onready var health_component = %HealthComponent

var movement_ticker = 0

var bob_velocity = 0
var base_position = Vector3(0,1,0)

var direction : Vector3

@onready var root_node = get_tree().get_root().get_child(0)

@export var grenade_throw_strength = 15

@onready var Camera = %Camera3D;
@onready var spring_arm = %SpringArm3D
@onready var ray_cast = %RayCast3D
@onready var gun_sprite = %GunSprite
@export var debug_decal: Decal
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var projectile_path = preload("res://projectile.tscn")
@export var explosion_sprite = preload("res://explosionsprite.tscn")
@export var grenade_scene = preload("res://grenade.tscn")

var can_shoot = true

var current_weapon : Resource =  null

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		self.rotate_y(-event.relative.x * MOUSE_SENS)
		spring_arm.rotate_x(-event.relative.y * MOUSE_SENS)
		spring_arm.rotation.x = clamp(spring_arm.rotation.x, -1.5, 1.5)
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	#print(Camera.position.y)
	pass
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		bob_velocity = sin(movement_ticker * 25)/50
		#bob_velocity = sin(movement_ticker) * 100
		spring_arm.position.y += bob_velocity

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_just_pressed("grenade"):
		throw_grenade(grenade_throw_strength)
	if current_weapon != null:
		if Input.is_action_pressed("shoot"):
			if can_shoot:
				shoot_ray()
				can_shoot = false
			gun_sprite.play("shoot")
		else:
			gun_sprite.play("no_shoot")
	
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if position.y < -10:
		position = Vector3(0,3,0)
	if direction:
		velocity.x = lerpf(velocity.x, direction.x * SPEED, ACCEL)
		velocity.z = lerpf(velocity.z, direction.z * SPEED, ACCEL)
		if is_on_floor(): movement_ticker += 1
	else:
		velocity.x = lerpf(velocity.x, 0, DECEL)
		velocity.z = lerpf(velocity.z, 0, DECEL)
		movement_ticker = 0
		spring_arm.position.y = lerpf(spring_arm.position.y, base_position.y, 0.1)
		
	#moving zoom
	if sign(input_dir.y) == -1:
		Camera.fov = lerpf(Camera.fov, MOVING_FOV, 0.25)
	else:
		Camera.fov = lerpf(Camera.fov, IDLE_FOV, 0.25)
	
	# view tilting
	Camera.rotation.z = lerpf(Camera.rotation.z, -(sign(input_dir.x) * VIEW_TILT), 0.25)
	move_and_slide()
	
func shoot_ray():
	if ray_cast.is_colliding():
		var collider = ray_cast.get_collider()
		var pos = ray_cast.get_collision_point()
		var norm = ray_cast.get_collision_normal()
		var randomizer_vector = Vector3(randf_range(-0.4,0.4),1,randf_range(-0.4,0.4))
		var gun_dmg = current_weapon.damage
		if collider != null:
			if collider.has_method("take_damage"):
				collider.take_damage(gun_dmg)
				make_explosion(root_node, collider.explosion_sprite, pos, 0.01)
			if collider is RigidBody3D:
				collider.apply_force(-Vector3(sin(rotation.y),-0.5, cos(rotation.y)) * gun_dmg * 10, collider.position - pos)
				
			debug_decal.position = pos
			#debug_decal.look_at(pos + norm, Vector3.UP)
			debug_decal.rotation.x = collider.rotation.x + 90

func pickup_weapon(weapon):
	current_weapon = weapon
	gun_sprite.sprite_frames = current_weapon.sprite_frames
	gun_sprite.speed_scale = current_weapon.fire_rate
	print(weapon)

func make_explosion(parent,sprite, pos, p_size):
	var new_explosion = sprite.instantiate()
	new_explosion.position = pos
	if p_size != -1:
		new_explosion.pixel_size = p_size
	parent.add_child(new_explosion)
	
func throw_grenade(strength):
	var new_grenade = grenade_scene.instantiate()
	new_grenade.position = position
	new_grenade.rotation_vector = -Vector3(sin(rotation.y),-0.5, cos(rotation.y)) + (velocity /  SPEED)
	new_grenade.throw_strength = strength
	root_node.add_child(new_grenade)

func shoot_projectile():
	var new_projectile = projectile_path.instantiate()
	root_node.add_child(new_projectile)
	new_projectile.position = position
	new_projectile.rotation = rotation
	new_projectile.rotation_vector = -Vector3(sin(rotation.y),0, cos(rotation.y))


func _on_shootcooldown_timeout():
	can_shoot = true
