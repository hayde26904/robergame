extends Node
class_name Projectile

@export var speed : int
@export var damage : int

@export var visual_direction : Vector3
@export var collision_direction : Vector3

@export var life_time : float

@export var collision : Node
@export var visual : Node
@export var despawn_timer : Timer

func _ready():
	despawn_timer.wait_time = life_time
	despawn_timer.timeout.connect(despawn)
	despawn_timer.start()
	
	collision.get_node("Area3D").body_entered.connect(collision_detected)

func _physics_process(delta):
	visual.velocity = visual_direction * speed
	collision.velocity = collision_direction * speed
	visual.move_and_slide()
	collision.move_and_slide()

func despawn():
	queue_free()
	
func collision_detected(body):
	pass
