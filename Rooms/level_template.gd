extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


 # Replace with function body.

onready var player = get_node("/root/Node2D/player")
onready var active_enemies = get_node("Enemies")
onready var enemylist = get_node("EnemyInstances")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _ready():
	#print("Enemy List: \n " ,enemylist.get_enemies())
	pass


func _on_CurrentRoom_body_entered(body):
	if body==player:
		player.respawn_coords()


func reload_enemies():
	var ens_to_respawn = enemylist.get_enemies()
	#print(enemylist.get_children())
	for enemy in active_enemies.get_children():
		active_enemies.remove_child(enemy)
	
	for i in range(len(ens_to_respawn)):
		print(ens_to_respawn[i][0])
		ens_to_respawn[i][0].get_parent().remove_child(ens_to_respawn[i][0])
		active_enemies.add_child(ens_to_respawn[i][0]) 
	
	for i in range(len(ens_to_respawn)):
		active_enemies.get_child(i).alive()
		active_enemies.get_child(i).position = ens_to_respawn[i][1]
		active_enemies.get_child(i).scale = ens_to_respawn[i][2]
		
#
#	for enemy in range(len(enemylist.length())):
#		active_enemies.add_child(enemylist.pop_inst())
#
		
	
	
