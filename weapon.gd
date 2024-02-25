extends Resource
class_name Weapon

@export_enum("Raycast", "Projectile") var collision_type : String
@export var projectile_scene: PackedScene
@export var sprite_frames : SpriteFrames
@export var pickup_texture : Texture2D
@export var pickup_size : float
@export var damage : int
@export var fire_rate : int
@export var fire_point : Vector2

func fire(root_node : Node3D, viewport : Viewport):
	var Camera = viewport.get_camera_3d()
	var viewport_center = viewport.get_visible_rect().size / 2
	
	print("goose")
	
	if collision_type == "Raycast":
		var ray = cast_ray(viewport_center, 1000, root_node, Camera)
		if ray != {}: print(ray)
	elif collision_type == "Projectile":
		var new_projectile = projectile_scene.instantiate()
		var fire_point_projected_pos = Camera.project_position(fire_point, 1)
		var target_point = Camera.project_position(viewport_center, 300)
		
		root_node.add_child(new_projectile)
		new_projectile.position = fire_point_projected_pos
		new_projectile.look_at(target_point, Vector3(0,1,0))
		
		new_projectile.direction = (target_point - new_projectile.position).normalized()
		#new_projectile.rotation.y = rotation.y
		#new_projectile.rotation.x = spring_arm.rotation.x
		"""new_projectile.direction = -Vector3(
		sin(rotation.y) * cos(new_projectile.rotation.x),
		-sin(new_projectile.rotation.x),
		cos(rotation.y) * cos(new_projectile.rotation.x)
		)"""
		
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
