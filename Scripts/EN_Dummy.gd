extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var dam = 25.0 setget, damage
export var hea = 100.0 setget , health
export var physics_enabled = true setget ,is_physics_enabled
export var speed = 100 setget , get_speed


func get_speed():
	return speed

func is_physics_enabled():
	return physics_enabled

func damage():
	return dam
	
func health():
	return hea

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
