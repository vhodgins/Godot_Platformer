extends Node2D
var healthbar_length = 32
onready var parent = get_node("../")
onready var bar = get_node("Fg")
onready var player = get_node("/root/Node2D/player")
onready var maincan = get_node("/root/Node2D/player/PlayerCanvas")
export var initial_scale = .25

func adjust_healthbar():
	if parent==player:
		bar.position.x = -(initial_scale-bar.scale.x)/2 * initial_scale*256
	bar.scale.x = (parent.get_health()+.0000001) / parent.get_max_health()
	
var healthbar = false
func _ready():
	if parent==maincan:
		parent = player
	if parent.has_healthbar():
		healthbar=true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if healthbar:
		adjust_healthbar()
	else:
		get_parent().remove_child(self)

