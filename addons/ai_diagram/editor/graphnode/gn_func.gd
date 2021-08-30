tool
extends GraphNode

signal kill_me
signal remove_slot
signal graphnode_updated

onready var gn_sub_param = preload("res://addons/ai_diagram/editor/graphnode/gn_sub_param.tscn")

func _ready():
	pass # Replace with function body.

func _on_btn_min_button_up():
	var idx = get_child_count()-1
	if idx > 2:
		remove_child(get_child(idx))
	emit_update_signal()

func add_slot():
	var o = gn_sub_param.instance()
	add_child(o)
	o.connect("sub_graphnode_updated", self, "emit_update_signal")
	
func _on_btn_plus_button_up():
	add_slot()
	emit_update_signal()

func _on_gn_func_close_request():
	emit_signal("kill_me", name)
	queue_free()

func get_data():
	var data = {}
	data["type"] = "gn_func"
	data["name"] = name
	data["offset"] = offset
	data["func"] = $le_name.text
	data["return"] = $HBoxContainer/le_return.text
	data["slot_count"] = get_child_count()-3
	for o in range( get_child_count()-3 ) :
		var c = get_child(o+3)
		data["slot_" + str(o)] = c.get_data()
	return data

func set_data(pdata):
	offset = pdata["offset"]
	name = pdata["name"]
	$le_name.text = pdata["func"]
	$HBoxContainer/le_return.text = pdata["return"]
	for o in pdata["slot_count"]:
		add_slot()
	for i in range(pdata["slot_count"]):
		var key = "slot_" + str(i)
		var slot = get_child(i + 3)
		slot.set_data(pdata[key])

func emit_update_signal():
	emit_signal("graphnode_updated")

func _on_le_name_text_changed(new_text):
	emit_update_signal()

func _on_le_return_text_changed(new_text):
	emit_update_signal()
