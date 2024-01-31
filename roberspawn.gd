extends Timer

@onready var rober = preload("res://rober.tscn")

var times_spawned = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_timeout():
	times_spawned += 1
	wait_time = 1 - times_spawned * 0.001
	var new_rober = rober.instantiate()
	new_rober.position = Vector3(randi_range(-100,100), 2, randi_range(-100,100))
	get_parent().add_child(new_rober)
