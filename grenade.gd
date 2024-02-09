extends RigidBody3D

@export var rotation_vector = Vector3.ZERO
@export var throw_strength = 10
# Called when the node enters the scene tree for the first time.
func _ready():
	linear_velocity = rotation_vector * throw_strength


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_3d_body_entered(body):
	if body != null and body.has_method("take_damage"):
		body.take_damage(100)
