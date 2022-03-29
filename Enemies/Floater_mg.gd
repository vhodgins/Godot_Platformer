extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var movement_vector = Vector2()
onready var parent = get_parent()


func move_gen(physics_enabled, iof, on_left, on_right):
	return Vector2(0,0)
	

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
