extends CharacterBody3D

const SPEED = 20
const ACCEL = 0.1
const DECEL = 0.1
const JUMP_VELOCITY = 20

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
@onready var viewport = get_viewport()

@export var grenade_throw_strength = 15

@onready var Camera = %Camera3D;
@onready var spring_arm = %SpringArm3D
@onready var ray_cast = %RayCast3D
@onready var gun_sprite = %GunSprite
@onready var crosshair = %Crosshair
@onready var fire_point = %FirePoint
@export var debug_decal: Decal
@onready var debug_mesh = %DebugMesh
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var explosion_sprite = preload("res://explosionsprite.tscn")
@export var grenade_scene = preload("res://grenade.tscn")

var can_shoot : bool = true
var should_shoot : bool = false

var current_weapon : Weapon =  null

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		self.rotate_y(-event.relative.x * MOUSE_SENS)
		spring_arm.rotate_x(-event.relative.y * MOUSE_SENS)
		spring_arm.rotation.x = clamp(spring_arm.rotation.x, -1.5, 1.5)
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()
			
func weapon_inputs():
	if Input.is_action_just_pressed("grenade"):
		throw_grenade(grenade_throw_strength)
	if current_weapon != null:
		if Input.is_action_pressed("shoot"):
			if can_shoot:
				current_weapon.fire(root_node, viewport, Camera)
				can_shoot = false
			gun_sprite.play("shoot")
		else:
			gun_sprite.play("no_shoot")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	#respawn player if they fall off the map (thanks maffew)
	if position.y < -10:
		position = Vector3(0,3,0)
	
	weapon_inputs()
	
	# I know this code is stupid but it's a necessary evil because godot is being silly and I'm tired
			
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		bob_velocity = sin(movement_ticker * 25)/50
		spring_arm.position.y += bob_velocity
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = lerpf(velocity.x, direction.x * SPEED, ACCEL)
		velocity.z = lerpf(velocity.z, direction.z * SPEED, ACCEL)
		if is_on_floor(): movement_ticker += 1
	else:
		velocity.x = lerpf(velocity.x, 0, DECEL)
		velocity.z = lerpf(velocity.z, 0, DECEL)
		movement_ticker = 0
		spring_arm.position.y = lerpf(spring_arm.position.y, base_position.y, 0.1)
	
	#zoom increase fov when moving forward
	if sign(input_dir.y) == -1:
		Camera.fov = lerpf(Camera.fov, MOVING_FOV, 0.25)
	else:
		Camera.fov = lerpf(Camera.fov, IDLE_FOV, 0.25)
	
	# view tilting
	Camera.rotation.z = lerpf(Camera.rotation.z, -(sign(input_dir.x) * VIEW_TILT), 0.25)
	move_and_slide()

func pickup_weapon(weapon : Weapon):
	current_weapon = weapon
	gun_sprite.sprite_frames = current_weapon.sprite_frames
	gun_sprite.speed_scale = current_weapon.fire_rate
	print(weapon)
	
func throw_grenade(strength):
	var new_grenade = grenade_scene.instantiate()
	new_grenade.position = position
	new_grenade.rotation_vector = -Vector3(sin(rotation.y),-0.5, cos(rotation.y)) + (velocity /  SPEED)
	new_grenade.throw_strength = strength
	root_node.add_child(new_grenade)

func _on_shootcooldown_timeout():
	can_shoot = true
