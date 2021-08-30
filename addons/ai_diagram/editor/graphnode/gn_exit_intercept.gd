tool
extends GraphNode

signal kill_me
signal remove_slot
signal graphnode_updated

export (bool) var intercept = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func get_data():
	var data = {}
	if intercept:
		data["type"] = "gn_exit_intercept"
	else:
		data["type"] = "gn_exit"
	data["name"] = name
	data["offset"] = offset
	return data

func _on_gn_intercept_exit_close_request():
	emit_signal("kill_me", name)
	queue_free()

func set_data(pdata):
	offset = pdata["offset"]
	name = pdata["name"]
