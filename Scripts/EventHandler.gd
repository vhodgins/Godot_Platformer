extends Node

## Event Handler is a node that will handle door opening, cutscenes, and game_wide variables 
var _enemies_defeated = false
onready var player = get_node("/root/Node2D/player")
onready var camera = get_node("/root/Node2D/player/MainCam")
onready var currentroom = get_node("../CurrentRoom")

func enemy_count():
	var en = get_node("../Enemies").get_child_count()
	if en==0:
		enemies_defeated()
		open_enemy_doors()
	return 
	
func enemies_defeated():
	_enemies_defeated = true
	
	
func open_enemy_doors():
	for door in get_node("../Doors/Enemy_doors").get_children():
			door.open()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _on_Area2D_body_entered(body):
	var area_size = currentroom.get_child(0).get_shape().extents
	if body==player:
		#print(area_size.x)
		camera.limit_left = get_parent().position.x - 64
		camera.limit_right = get_parent().position.x + area_size.x*1.88  + 128
		camera.limit_top = get_parent().position.y - 64
		camera.limit_bottom = get_parent().position.y + area_size.y*1.78 + 64
		


func _on_I_Weapon_body_entered(body):
	if body==player:
		open_control_door(0)
		player.get_node("PlayerStats").update_eq(["weapon",1])
		player.set_damage(player.get_node("PlayerStats").equipped()["weapon"][0] )


func open_control_door(arg):
	if get_node("../Doors/Event_doors"):
		var door = get_node("../Doors/Event_doors").get_child(arg)
		door.open()


func _on_I_grapple_body_entered(body):
	if body==player:
		player.get_node("PlayerStats").update_eq(["grapple", true])
		player.update_grapple()
