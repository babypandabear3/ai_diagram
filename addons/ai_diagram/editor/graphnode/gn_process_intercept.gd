tool
extends GraphNode

signal kill_me
signal remove_slot
signal graphnode_updated

# Called when the node enters the scene tree for the first time.
func _ready():
	_on_btn_plus_button_up()
	pass # Replace with function body.

func add_slot():
	var o = Label.new()
	add_child(o)
	set_slot(get_child_count()-1, false, 0, Color.white, true, 1, Color.red)
	
func _on_btn_plus_button_up():
	add_slot()
	emit_signal("graphnode_updated")
	
func _on_btn_min_button_up():
	var idx = get_child_count()-1
	if idx > 4:
		remove_child(get_child(idx))
		emit_signal("remove_slot", name, idx)

func _on_gn_process_close_request():
	emit_signal("kill_me", name)
	queue_free()

func get_data():
	
		
	var data = {}
	data["type"] = "gn_process_intercept"
	data["name"] = name
	data["offset"] = offset
	data["runtype"] = $ob_runtype.get_item_text($ob_runtype.selected)
	data["runlength"] = $le_runlength.text
	if $le_runlength.text == "":
		data["runlength"] = "0"
	data["process"] = $le_name.text
	data["slot_count"] = get_child_count()-4
	return data
	
func get_ob_runtype_text_idx(text):
	var ret = -1
	for i in range( $ob_runtype.get_item_count() ):
		var t = $ob_runtype.get_item_text(i)
		if t == text:
			ret = i
			break
	return ret
	
func set_data(pdata):
	offset = pdata["offset"]
	name = pdata["name"]
	$le_name.text = pdata["process"]
	var ob_runtype_selected = get_ob_runtype_text_idx(pdata["runtype"])
	$ob_runtype.selected = ob_runtype_selected
	$le_runlength.text = pdata["runlength"]
	for o in pdata["slot_count"]-1:
		add_slot()

func _on_ob_time_item_selected(index):
	emit_signal("graphnode_updated")


func _on_le_name_text_changed(new_text):
	emit_signal("graphnode_updated")


func _on_le_runlength_text_changed(new_text):
	emit_signal("graphnode_updated")
