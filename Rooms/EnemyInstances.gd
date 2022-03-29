extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var enemies = get_node("../Enemies")

var instance_vector = [] setget , get_enemies

func append_inst(inst):
	if not inst in instance_vector :
		instance_vector.append(inst)
	#print("Appending enemy, current state \n", instance_vector)
#
#func respawn():
#	var ent 
#	for i in range(len(instance_vector)):
#		ent = instance_vector[0]
#		instance_vector.pop_front()
#		enemies.add_child(ent)
#
#
func clear_enemies():
	instance_vector = []
	
func get_enemies():
	#print(instance_vector)
	return instance_vector
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
