extends Node2D

var velocity = Vector2()
var rotation_dir = 0
onready var player = get_node("../")
onready var stats = get_node("../PlayerStats")
onready var melee_detector = get_node("Node2D/MeleeRay")
onready var melee_node = get_node("Node2D")
var striking = 0 setget , get_striking_speed
enum Strike_state {NOT_STRIKING, STRIKING, RETRACTING} 
export var _strike_state : int = Strike_state.NOT_STRIKING setget ,is_striking
var dam
var dam_range
var dam_speed

func _ready():
	update_attack()

func update_attack():
	var inv = stats.equipped()
	#print(inv)
	dam = inv["weapon"][0]
	if dam==0:
		self.hide()
	else:
		self.show()
	dam_range = inv["weapon"][1]
	dam_speed = inv["weapon"][2]
	


func get_movement_keys():
	var left = Input.is_action_just_pressed("ui_left")
	var right = Input.is_action_just_pressed("ui_right")
	var up = Input.is_action_just_pressed("ui_up")
	var down = Input.is_action_just_pressed("ui_down")
	
	return Vector2(int(right)-int(left), int(down)-int(up))

func get_left_stick():
	return Input.get_vector("LS_left", "LS_right", "LS_up", "LS_down")
	

func get_input():
	var dir = get_left_stick()
	if (player.get_grapple_state()==0) and dir.length()>.5:
		rotation = dir.angle() + PI

func strike(delta):
	var a = Input.is_action_just_pressed("x")
	if striking>=0:
		striking-=delta
	
	if striking < .1:
		player.can_take_damage(true)
	
	match _strike_state:
		Strike_state.NOT_STRIKING:
			melee_node.position.x = -dam_speed
			get_input()
			if a and (striking<0):
				_strike_state = Strike_state.STRIKING
				player.velocity = Vector2(-150,0).rotated(rotation) - Vector2(500*cos(rotation),0)
				player.can_take_damage(false)
				striking = .25
			
		Strike_state.STRIKING:
			melee_node.position.x -=dam_speed
			if melee_node.position.x<-1*dam_range:
				_strike_state = Strike_state.RETRACTING
		
		Strike_state.RETRACTING:
			melee_node.position.x +=dam_speed/2
			if melee_node.position.x >= -30:
				_strike_state = Strike_state.NOT_STRIKING

func get_striking_speed():
	return striking

func is_striking():
	return _strike_state

func _physics_process(delta):
	strike(delta)
