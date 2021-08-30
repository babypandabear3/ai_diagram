tool
extends GraphNode

signal kill_me
signal remove_slot
signal graphnode_updated

var sub = preload("res://addons/ai_diagram/editor/graphnode/gn_sub_if_statement.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_btn_min_button_up():
	var idx = get_child_count()-1
	if idx > 0:
		remove_child(get_child(idx))
		emit_signal("remove_slot", name, idx)

func add_slot():
	var o = sub.instance()
	add_child(o)
	set_slot(get_child_count()-1, false, 2, Color.green, true, 2, Color.green)
	o.set_conn_port( get_child_count()-2)
	
func _on_btn_plus_button_up():
	add_slot()
	emit_signal("graphnode_updated")
	
func get_data():
	var data = {}
	data["type"] = "gn_intercept"
	data["name"] = name
	data["offset"] = offset
	data["slot_count"] = get_child_count()-1
	for o in range(get_child_count()-1):
		var c = get_child(o+1)
		data["slot_" + str(o)] = c.get_data()
		
	return data

func set_data(pdata):
	offset = pdata["offset"]
	name = pdata["name"]
	for i in range(pdata["slot_count"]):
		add_slot()
		var key = "slot_" + str(i)
		var slot = get_child(i + 1)
		slot.set_data(pdata[key])
