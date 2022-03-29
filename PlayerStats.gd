extends Node2D

   #[dam, range, speed, name]
var melee = [
	[0, 0 ,0, "none"],
	[51, 100, 30, "Blaster"],
	[101, 200, 50, "Killer"]
	]


var _inventory = [
] setget update_inv , inventory

var _equipped = {
	"grapple" : false,
	"weapon"   : melee[0]
} setget  update_eq ,equipped

var _stats = {
	"health" : 100, 
	"jumps"  : 1,
	"wall-jumps" : 1,
	"grapples" : 1
} setget  update_stats , stats 


func inventory():
	return _inventory
#
func update_inv(param):
	_inventory.append(param)
	update_player()

func equipped():
	return _equipped
	
func update_eq(param):
	if param[0]=="weapon":
		_equipped[param[0]] = melee[param[1]]
	if param[0]=="grapple":
		_equipped[param[0]] = param[1]
	update_player()
	
func stats():
	return _stats 
	
func update_stats(param):
	_stats[param[0]] = param[1]
	update_player()

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
func update_player():
	get_parent().get_node("Melee").update_attack()
	get_parent().get_node("Grapple").update_grapple()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
