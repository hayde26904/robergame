extends Resource
class_name Weapon

@export_enum("Raycast", "Projectile") var collision_type : String
@export var projectile_visual_scene: PackedScene
@export var projectile_collision_scene: PackedScene
@export var sprite_frames : SpriteFrames
@export var pickup_texture : Texture2D
@export var pickup_size : float
@export var damage : int
@export var fire_rate : int
@export var fire_point : Vector2

func fire(root_node : Node3D, viewport : Viewport):
	var Camera = viewport.get_camera_3d()
	var viewport_center = viewport.get_visible_rect().size / 2
	
	if collision_type == "Raycast":
		var ray = cast_ray(viewport_center, 1000, root_node, Camera)
		if ray != {}: print(ray)
	elif collision_type == "Projectile":
		
		var visual_projectile = projectile_visual_scene.instantiate()
		var collision_projectile = projectile_collision_scene.instantiate()
		
		var fire_point_3D = Camera.project_position(fire_point, 1)
		var viewport_center_3D = Camera.project_position(viewport_center, 0)
		var target_point = Camera.project_position(viewport_center, 100)
		
		root_node.add_child(visual_projectile)
		root_node.add_child(collision_projectile)
		
		visual_projectile.position = fire_point_3D
		collision_projectile.position = viewport_center_3D
		
		visual_projectile.look_at(target_point, Vector3.UP)
		collision_projectile.look_at(target_point, Vector3.UP)
		
		visual_projectile.direction = (target_point - visual_projectile.position).normalized()
		collision_projectile.direction = (target_point - collision_projectile.position).normalized()
		
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
