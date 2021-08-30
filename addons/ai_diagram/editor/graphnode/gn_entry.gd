tool
extends GraphNode

signal kill_me
signal remove_slot
signal graphnode_updated

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func get_data():
	var data = {}
	data["type"] = "gn_entry"
	data["name"] = name
	data["offset"] = offset
	return data

func set_data(pdata):
	offset = pdata["offset"]
	name = pdata["name"]
