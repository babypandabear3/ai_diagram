tool
extends HBoxContainer

signal sub_graphnode_updated

var conn_port = -1
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_conn_port(par):
	conn_port = par
	
func get_data():
	var data = {}
	data["left"] = $le_left.text
	data["operator"] = $ob_operator.get_item_text($ob_operator.selected)
	data["datatype"] = $ob_datatype.get_item_text($ob_datatype.selected)
	data["right"] = $le_right.text
	data["conn_port"] = conn_port
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
	$le_left.text = pdata["left"]
	$le_right.text = pdata["right"]
	get_ob_text_idx(pdata["operator"], $ob_operator)
	get_ob_text_idx(pdata["datatype"], $ob_datatype)
