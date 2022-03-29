extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var player = get_node("/root/Node2D/player")
onready var damage = self.get_parent().get_damage_output()
onready var room = get_parent().get_parent().get_parent().get_parent()
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if self.overlaps_body(player):
		player.take_damage(damage, self.get_angle_to(player.position), room)
