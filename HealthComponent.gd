extends Node

@export var max_health = 50
@export var health = max_health

@onready var root_node = get_tree().get_root().get_child(0)
@onready var parent = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func take_damage(dmg):
	health -= dmg
