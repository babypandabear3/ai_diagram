tool
extends GraphNode

signal graphnode_updated

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_gn_set_value_close_request():
	emit_signal("kill_me", name)
	queue_free()

func get_data():
	var data = {}
	data["type"] = "gn_set_value"
	data["name"] = name
	data["offset"] = offset
	data["var"] = $le_var.text
	data["value"] = $gn_sub_param.get_data()
	return data

func set_data(pdata):
	offset = pdata["offset"]
	name = pdata["name"]
	$le_var.text = pdata["var"]
	$gn_sub_param.set_data(pdata["value"])
