extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var children = self.get_children()
### Function of Node : 

## Wakes up enemies when player enters room

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_CurrentRoom_body_entered(body):
	for child in children:
		#print("Waking: "+ child.name)
		child.wake()
