extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var move_speed = get_parent().get_speed()
onready var entity = get_node("../Enemy")


func move_gen(physics_enabled, iof, on_left, on_right):
	if physics_enabled and iof:
		if abs(entity.velocity.x)<500:
			entity.velocity.x += move_speed
		if on_right and (entity.velocity.x>0):
			move_speed = -move_speed
		elif on_left and (entity.velocity.x<0):
			move_speed = -move_speed


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
