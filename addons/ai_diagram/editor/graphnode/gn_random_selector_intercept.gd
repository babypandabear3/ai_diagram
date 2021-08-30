tool
extends GraphNode

signal kill_me
signal remove_slot
signal graphnode_updated

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_btn_min_button_up():
	var idx = get_child_count()-1
	if idx > 1:
		remove_child(get_child(idx))
		emit_signal("remove_slot", name, idx)

func add_slot():
	var o = Label.new()
	add_child(o)
	set_slot(get_child_count()-1, false, 0, Color.white, true, 2, Color.green)
	
func _on_btn_plus_button_up():
	add_slot()
	emit_signal("graphnode_updated")

func _on_gn_random_selector_close_request():
	emit_signal("kill_me", name)
	queue_free()

func get_data():
	var data = {}
	data["type"] = "gn_random_selector_intercept"
	data["name"] = name
	data["offset"] = offset
	data["slot_count"] = get_child_count()-1
	return data

func set_data(pdata):
	offset = pdata["offset"]
	name = pdata["name"]
	for o in pdata["slot_count"]-1:
		add_slot()
