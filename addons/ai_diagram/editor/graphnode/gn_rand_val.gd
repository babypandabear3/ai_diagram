tool
extends GraphNode

signal kill_me
signal remove_slot
signal graphnode_updated

onready var hb2 = $hb2
onready var hb3 = $hb3
onready var chknorm = $chk_norm

onready var min1 = $hb1/le_min
onready var max1 = $hb1/le_max

# Called when the node enters the scene tree for the first time.
func _ready():
	hb2.hide()
	hb3.hide()
	chknorm.hide()
	chknorm.pressed = true



func _on_OptionButton_item_selected(index):
	match index:
		0:
			hb2.hide()
			hb3.hide()
			chknorm.hide()
			min1.text = "0"
			max1.text = "1"
		1:
			hb2.hide()
			hb3.hide()
			chknorm.hide()
			min1.text = "0"
			max1.text = "1"
		2:
			hb2.show()
			hb3.hide()
			chknorm.show()
			min1.text = "-1"
			max1.text = "1"
			
		3:
			hb2.show()
			hb3.show()
			chknorm.show()
			min1.text = "-1"
			max1.text = "1"
			

func _on_gn_rand_val_close_request():
	emit_signal("kill_me", name)
	queue_free()

func get_data():
	var data = {}
	data["type"] = "gn_rand_val"
	data["name"] = name
	data["offset"] = offset
	data["result"] = $HBoxContainer/le_result.text
	data["datatype"] = $ob_datatype.get_item_text($ob_datatype.selected)
	data["min1"] = $hb1/le_min.text
	data["max1"] = $hb1/le_max.text
	data["min2"] = $hb2/le_min.text
	data["max2"] = $hb2/le_max.text
	data["min3"] = $hb3/le_min.text
	data["max3"] = $hb3/le_max.text
	data["normalized"] = $chk_norm.pressed
	return data

func get_ob_text_idx(text, ob):
	var ret = -1
	for i in range( ob.get_item_count() ):
		if ob.get_item_text(i) == text:
			ret = i
			break
	ob.selected = ret
	_on_OptionButton_item_selected(ret)
	return ret
	
func set_data(pdata):
	offset = pdata["offset"]
	name = pdata["name"]
	$HBoxContainer/le_result.text = pdata["result"]
	get_ob_text_idx(pdata["datatype"], $ob_datatype)
	$hb1/le_min.text = pdata["min1"]
	$hb1/le_max.text = pdata["max1"]
	$hb2/le_min.text = pdata["min2"]
	$hb2/le_max.text = pdata["max2"]
	$hb3/le_min.text = pdata["min3"]
	$hb3/le_max.text = pdata["max3"]
	$chk_norm.pressed = pdata["normalized"]
	
