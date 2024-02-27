extends Projectile
class_name Laser

func collision_detected(body):
	if body.has_node("HealthComponent"):
		body.get_node("HealthComponent").take_damage(damage)
		if body.has_method("make_damage_particle"):
			body.make_damage_particle(collision.position, 1)
	queue_free()
