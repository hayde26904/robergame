extends CharacterBody3D

const SPEED = 20
const ACCEL = 0.5
const DECEL = 0.5
const JUMP_VELOCITY = 7

const VIEW_TILT = 0.09
const IDLE_FOV = 75
const MOVING_FOV = 95

const MOUSE_SENS = 0.008

@onready var health_component = %HealthComponent

var movement_ticker = 0

var bob_velocity = 0
var base_position = Vector3(0,1,0)

@onready var root_node = get_tree().get_root().get_child(0)

@onready var Camera = %Camera3D;
@onready var spring_arm = %SpringArm3D
@onready var ray_cast = %RayCast3D
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var projectile_path = preload("res://projectile.tscn")

var can_shoot = true

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		self.rotate_y(-event.relative.x * MOUSE_SENS)
		spring_arm.rotate_x(-event.relative.y * MOUSE_SENS)
		spring_arm.rotation.x = clamp(spring_arm.rotation.x, -0.5, 1.2)
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	#print(Camera.position.y)
	#var ray_collider = ray_cast.get_collider()
	#if ray_collider != null:
		#if ray_collider.is_in_group("rober"):
			#print("ROBER!!")
			
	print(ray_cast.get_collider())

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		bob_velocity = sin(movement_ticker * 25)/50
		Camera.position.y += bob_velocity

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()
		can_shoot = false
	
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if position.y < -10:
		position = Vector3(0,3,0)
	
	if direction:
		velocity.x = lerpf(velocity.x, direction.x * SPEED, ACCEL)
		velocity.z = lerpf(velocity.z, direction.z * SPEED, ACCEL)
		movement_ticker += 1
	else:
		velocity.x = lerpf(velocity.x, 0, DECEL)
		velocity.z = lerpf(velocity.z, 0, DECEL)
		movement_ticker = 0
		Camera.position.y = lerpf(Camera.position.y, base_position.y, 0.1)
	
	#moving zoom
	if input_dir.y == -1:
		Camera.fov = lerpf(Camera.fov, MOVING_FOV, 0.25)
	elif input_dir.y == 0 or input_dir.y == 1:
		Camera.fov = lerpf(Camera.fov, IDLE_FOV, 0.25)
	
	# view tilting
	if input_dir.x != 0:
		Camera.rotation.z = lerpf(Camera.rotation.z, -(input_dir.x * VIEW_TILT), 0.25)
	elif input_dir.x == 0:
		Camera.rotation.z = lerpf(Camera.rotation.z, 0, 0.25)

	move_and_slide()

func shoot():
	var new_projectile = projectile_path.instantiate()
	root_node.add_child(new_projectile)
	new_projectile.position = position
	new_projectile.rotation = rotation
	new_projectile.rotation_vector = -Vector3(sin(rotation.y),0, cos(rotation.y))


func _on_shootcooldown_timeout():
	can_shoot = true
