tool
extends GraphNode

signal kill_me
signal remove_slot
signal graphnode_updated

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_gn_math_close_request():
	emit_signal("kill_me", name)
	queue_free()

func get_data():
	var data = {}
	data["type"] = "gn_math"
	data["name"] = name
	data["offset"] = offset
	data["result"] = $HBoxContainer/le_result.text
	data["operator"] = $HBoxContainer/ob_operator.get_item_text($HBoxContainer/ob_operator.selected)
	data["datatype"] = $HBoxContainer/ob_datatype.get_item_text($HBoxContainer/ob_datatype.selected)
	data["value"] = $HBoxContainer/le_value.text
	return data

func get_ob_text_idx(text, ob):
	var ret = -1
	for i in range( ob.get_item_count() ):
		if ob.get_item_text(i) == text:
			ret = i
			break
	ob.selected = ret
	return ret
	
func set_data(pdata):
	offset = pdata["offset"]
	name = pdata["name"]
	$HBoxContainer/le_result.text = pdata["result"]
	$HBoxContainer/le_value.text = pdata["value"]
	get_ob_text_idx(pdata["operator"], $HBoxContainer/ob_operator)
	get_ob_text_idx(pdata["datatype"], $HBoxContainer/ob_datatype)
	
