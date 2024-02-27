extends Weapon
class_name TestBlaster

@export var sprite_frames : SpriteFrames
@export var pickup_texture : Texture2D
@export var pickup_size : float

func fire(root_node : Node3D, viewport : Viewport, Camera : Camera3D):
	
	var new_projectile = projectile_scene.instantiate()
	
	var visual = new_projectile.visual
	var collision = new_projectile.collision
	
	var viewport_center = viewport.get_visible_rect().size / 2
	var fire_point_3D = Camera.project_position(fire_point, 1)
	var viewport_center_3D = Camera.project_position(viewport_center, 0)
	var target_point = Camera.project_position(viewport_center, 100)
	
	root_node.add_child(new_projectile)
	
	visual.global_position = fire_point_3D
	collision.global_position = viewport_center_3D
	
	visual.look_at(target_point, Vector3.UP)
	collision.look_at(target_point, Vector3.UP)
	
	new_projectile.visual_direction = (target_point - visual.global_position).normalized()
	new_projectile.collision_direction = (target_point - collision.global_position).normalized()
