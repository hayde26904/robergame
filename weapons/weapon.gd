extends Resource
class_name Weapon

@export var projectile_scene : PackedScene
@export var damage : int
@export var fire_rate : int
@export var fire_point : Vector2

func fire(root_node : Node3D, viewport : Viewport, Camera : Camera3D):
	pass
		
func cast_ray(origin : Vector2, length : int, root_node : Node3D, camera : Camera3D):
	var ray_length = length
	var from = camera.project_ray_origin(origin)
	var to = from + camera.project_ray_normal(origin) * ray_length
	var space = root_node.get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	var raycast_result = space.intersect_ray(ray_query)
	return(raycast_result)
