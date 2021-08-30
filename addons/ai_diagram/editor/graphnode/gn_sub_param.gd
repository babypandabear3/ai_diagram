tool
extends HBoxContainer

signal sub_graphnode_updated

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func get_data():
	var data = {}
	data["datatype"] = $ob_type.get_item_text($ob_type.selected)
	data["value"] = $le_value.text
	return data

func _on_ob_type_item_selected(index):
	emit_signal("sub_graphnode_updated")


func _on_le_value_text_changed(new_text):
	emit_signal("sub_graphnode_updated")

func get_ob_text_idx(text, ob):
	var ret = -1
	for i in range( ob.get_item_count() ):
		if ob.get_item_text(i) == text:
			ret = i
			break
	ob.selected = ret
	return ret
	
func set_data(pdata):
	$le_value.text = pdata["value"]
	get_ob_text_idx(pdata["datatype"], $ob_type)
	
