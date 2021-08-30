tool
extends Panel
signal start_diagram
class_name Ai_Diagram_Editor

signal update_resource_data

onready var context_menu = $PopupMenu
onready var graph : GraphEdit = $GraphEdit
var gn_pos = Vector2()
onready var gn_process = preload("res://addons/ai_diagram/editor/graphnode/gn_process.tscn")
onready var gn_func = preload("res://addons/ai_diagram/editor/graphnode/gn_func.tscn")
onready var gn_if_pcs = preload("res://addons/ai_diagram/editor/graphnode/gn_if_pcs.tscn")
onready var gn_rand_val = preload("res://addons/ai_diagram/editor/graphnode/gn_rand_val.tscn")
onready var gn_math = preload("res://addons/ai_diagram/editor/graphnode/gn_math.tscn")
onready var gn_random_selector = preload("res://addons/ai_diagram/editor/graphnode/gn_random_selector.tscn")
onready var gn_set_value = preload("res://addons/ai_diagram/editor/graphnode/gn_set_value.tscn")
onready var gn_entry = preload("res://addons/ai_diagram/editor/graphnode/gn_entry.tscn")
onready var gn_intercept = preload("res://addons/ai_diagram/editor/graphnode/gn_intercept.tscn")
onready var gn_exit = preload("res://addons/ai_diagram/editor/graphnode/gn_exit.tscn")
onready var gn_process_intercept = preload("res://addons/ai_diagram/editor/graphnode/gn_process_intercept.tscn")
onready var gn_if_pcs_intercept = preload("res://addons/ai_diagram/editor/graphnode/gn_if_pcs_intercept.tscn")
onready var gn_random_selector_intercept = preload("res://addons/ai_diagram/editor/graphnode/gn_random_selector_intercept.tscn")
onready var gn_exit_intercept = preload("res://addons/ai_diagram/editor/graphnode/gn_exit_intercept.tscn")

onready var panel_start = $Panel_start

onready var circleW : Texture = preload("res://addons/ai_diagram/circleW.png")
onready var circleR : Texture = preload("res://addons/ai_diagram/circleR.png")
onready var circleG : Texture = preload("res://addons/ai_diagram/circleG.png")

var plugin_node

var data_from_plugin_node
var fire_update_signal = true

var undo_redo

# Called when the node enters the scene tree for the first time.
func _ready():
	graph.set_right_disconnects(true)
	context_menu.connect("index_pressed", self, "_on_context_menu_index_pressed")
	context_menu.clear()
	context_menu.add_icon_item(circleW, "Entry")
	context_menu.add_icon_item(circleW, "Process")
	context_menu.add_icon_item(circleW, "If Pcs")
	context_menu.add_icon_item(circleW, "Random Selector")
	context_menu.add_icon_item(circleW, "Exit")
	context_menu.add_icon_item(circleR, "Func")
	context_menu.add_icon_item(circleR, "Set Value")
	context_menu.add_icon_item(circleR, "Random Value")
	context_menu.add_icon_item(circleR, "Math")
	context_menu.add_icon_item(circleG, "Intercept")
	context_menu.add_icon_item(circleG, "Process Intercept")
	context_menu.add_icon_item(circleG, "If Pcs Intercept")
	context_menu.add_icon_item(circleG, "Random Selector Intercept")
	context_menu.add_icon_item(circleG, "Exit Intercept")
	context_menu.add_icon_item(circleG, "Clear")
	
func set_graphnode_position(o):
	var newpos = graph.rect_pivot_offset + graph.scroll_offset
	newpos = newpos + (graph.scroll_offset * (1-graph.zoom))
	o.offset = newpos
	
	var offset2 = gn_pos - o.rect_global_position
	offset2 = offset2 * (1 + (1-graph.zoom))
	newpos = newpos + offset2
	o.offset = newpos

	
func set_owner_to_child(par_owner, par_obj):
	for o in par_obj.get_children():
		set_owner_to_child(par_owner, o)
	par_obj.owner = par_owner
	par_obj.filename = ""
	
	
func graphnode_setup(o):
	o.connect("kill_me", self, "child_deleted")
	o.connect("remove_slot", self, "slot_deleted")
	o.add_to_group("aid_graphnode")
	o.show_close = true
	graph.add_child(o)
	
	set_owner_to_child(graph, o)
	o.owner = graph
	o.filename = ""
	set_graphnode_position(o)
	if fire_update_signal:
		emit_signal("update_resource_data", self)
	o.connect("graphnode_updated", self, "graphnode_updated")

	
func _on_GraphEdit_connection_request(from, from_slot, to, to_slot):
	var conn = graph.get_connection_list()
	var to_del = []
	for c in conn:
		if c["from"] == from and c["from_port"] == from_slot:
			to_del.append(c)
			
	for c in to_del:
		graph.disconnect_node(c["from"], c["from_port"], c["to"], c["to_port"])
	
	graph.connect_node(from, from_slot, to, to_slot)
	emit_signal("update_resource_data", self)


func _on_GraphEdit_disconnection_request(from, from_slot, to, to_slot):
	graph.disconnect_node(from, from_slot, to, to_slot)
	emit_signal("update_resource_data", self)

	
func _on_context_menu_index_pressed(index):
	var gn = context_menu.get_item_text(index)
	match gn:
		"Process" : 
			var o = gn_process.instance()
			graphnode_setup(o)
		"Func" : 
			var o = gn_func.instance()
			graphnode_setup(o)
		"If Pcs":
			var o = gn_if_pcs.instance()
			graphnode_setup(o)
		"Random Value":
			var o = gn_rand_val.instance()
			graphnode_setup(o)
		"Math":
			var o = gn_math.instance()
			graphnode_setup(o)
		"Random Selector":
			var o = gn_random_selector.instance()
			graphnode_setup(o)
		"Set Value":
			var o = gn_set_value.instance()
			graphnode_setup(o)
		"Entry":
			if not_yet("gn_entry"):
				var o = gn_entry.instance()
				o.add_to_group("gn_entry")
				graphnode_setup(o)
		"Intercept":
			if not_yet("gn_intercept"):
				var o = gn_intercept.instance()
				o.add_to_group("gn_intercept")
				graphnode_setup(o)
		"Exit":
			var o = gn_exit.instance()
			graphnode_setup(o)
		"Process Intercept" : 
			var o = gn_process_intercept.instance()
			graphnode_setup(o)
		"If Pcs Intercept":
			var o = gn_if_pcs_intercept.instance()
			graphnode_setup(o)
		"Random Selector Intercept":
			var o = gn_random_selector_intercept.instance()
			graphnode_setup(o)
		"Clear":
			clear_everything()
		"Exit Intercept":
			var o = gn_exit_intercept.instance()
			graphnode_setup(o)
			
func not_yet(group_name):
	var ret = true
	for o in graph.get_children():
		if o.is_in_group(group_name):
			ret = false
	return ret
	
func content_position(pos):
	return (pos - graph.rect_position - graph.rect_pivot_offset * (Vector2.ONE - graph.rect_scale)) * 1.0/graph.rect_scale

func child_deleted(child_name):
	call_deferred("delete_child", child_name)
	
func delete_child(child_name = ""):
	var to_del = []
	var conn_list = graph.get_connection_list()
	for c in conn_list:
		if c["from"] == child_name:
			to_del.append(c)
		if c["to"] == child_name:
			to_del.append(c)
	for c in to_del:
		graph.disconnect_node(c["from"], c["from_port"], c["to"], c["to_port"])
	#call_deferred("graphnode_updated")
	$timer_update_resource.start()
	#emit_signal("update_resource_data", self)

func slot_deleted(child_name, slot_idx):
	var to_del = []
	var conn_list = graph.get_connection_list()
	for c in conn_list:
		if c["from"] == child_name and c["from_port"] == slot_idx-1:
			to_del.append(c)
	
	for c in to_del:
		graph.disconnect_node(c["from"], c["from_port"], c["to"], c["to_port"])
	emit_signal("update_resource_data", self)

func _on_btn_start_button_up():
	emit_signal("start_diagram")
	panel_start.hide()
	emit_signal("update_resource_data", self)

func show_start():
	panel_start.show()
	
func hide_start():
	panel_start.hide()

func _on_GraphEdit__end_node_move():
	emit_signal("update_resource_data", self)

func get_editor_data():
	var data = []
	data.append(["graph"])
	data.append(graph.get_connection_list())
	return data

func rebuild_view(data):
	for o in graph.get_children():
		if o.is_in_group("aid_graphnode"):
			o.queue_free()
	data_from_plugin_node = data
	
	for o in graph.get_connection_list():
		graph.disconnect_node(o["from"], o["from_port"], o["to"], o["to_port"])
	$timer_remake_data.start()
	#call_deferred("rebuild_graphnode", data)
	
func rebuild_graphnode(data):
	fire_update_signal = false
	var nodes = data.get_gnodes()
	var conn = data.get_connection()
	graph.scroll_offset = data.get_scroll_offset()

	for i in range(nodes.size()):
		var obj = nodes[i]

		var o = null
		match obj.type:
			"gn_entry":
				o = gn_entry.instance()
				o.add_to_group("gn_entry")
				graphnode_setup(o)
			"gn_exit":
				o = gn_exit.instance()
				graphnode_setup(o)
			"gn_func":
				o = gn_func.instance()
				graphnode_setup(o)
			"gn_if_pcs":
				o = gn_if_pcs.instance()
				graphnode_setup(o)
			"gn_intercept":
				o = gn_intercept.instance()
				o.add_to_group("gn_intercept")
				graphnode_setup(o)
			"gn_math":
				o = gn_math.instance()
				graphnode_setup(o)
			"gn_process":
				o = gn_process.instance()
				graphnode_setup(o)
			"gn_random_selector":
				o = gn_random_selector.instance()
				graphnode_setup(o)
			"gn_rand_val":
				o = gn_rand_val.instance()
				graphnode_setup(o)
			"gn_set_value":
				o = gn_set_value.instance()
				graphnode_setup(o)
			"gn_process_intercept":
				o = gn_process_intercept.instance()
				graphnode_setup(o)
			"gn_if_pcs_intercept":
				o = gn_if_pcs_intercept.instance()
				graphnode_setup(o)
			"gn_random_selector_intercept":
				o = gn_random_selector_intercept.instance()
				graphnode_setup(o)
			"gn_exit_intercept":
				o = gn_exit_intercept.instance()
				graphnode_setup(o)
		if o.has_method("set_data"):
			o.set_data(obj)
	
	for o in conn:
		graph.connect_node(o["from"], o["from_port"], o["to"], o["to_port"])

	
	fire_update_signal = true

func get_gnodes():
	var ret = []
	for o in graph.get_children():
		if o is GraphNode:
			if o.has_method("get_data"):
				ret.append(o.get_data())
	
	return ret

func get_connection_list():
	return graph.get_connection_list()

func set_plugin_node(par):
	plugin_node = par

func graphnode_updated():
	emit_signal("update_resource_data", self)


func _on_Timer_timeout():
	graphnode_updated()


func _on_timer_remake_data_timeout():
	rebuild_graphnode(data_from_plugin_node)

func get_scroll_offset():
	return graph.scroll_offset


func _on_GraphEdit_popup_request(position):
	context_menu.rect_position = position
	gn_pos = position
	context_menu.popup()

func clear_everything():
	for o in graph.get_connection_list():
		graph.disconnect_node(o.from, o.from_port, o.to, o.to_port)
	for o in graph.get_children():
		if o.is_in_group("aid_graphnode"):
			o.queue_free()
	emit_signal("update_resource_data", self)
