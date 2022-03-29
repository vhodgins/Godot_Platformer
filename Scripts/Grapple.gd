extends RayCast2D

var velocity = Vector2()
var rotation_dir = 0
onready var player = get_node("../")
onready var stats = get_node("../PlayerStats")


func get_right_stick():
	return Input.get_vector("RS_left", "RS_right", "RS_up", "RS_down")
	
	
func _ready():
	if stats.equipped()["grapple"]:
		self.show()
		
func update_grapple():
	self.show()

func get_input():
	var dir = get_right_stick()
	if (player.get_grapple_state()==0) and dir.length()>.5:
		rotation = dir.angle() + PI

func _physics_process(delta):
	get_input()
