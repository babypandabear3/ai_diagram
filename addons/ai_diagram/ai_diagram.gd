tool
extends Node

class_name AI_DIAGRAM
export (Resource) var datares
export (bool) var active = true
var white_nodes = {}
var red_nodes = {}
var conns = {}
var normal_start_name = ""

var _first = true
var _first_intercept = true

var prev = ""
var current = ""
var next = ""

var intercept_start_name = ""
var intercept_prev = ""
var intercept_current = ""
var intercept_next = ""
var process_intercept = false
var timer_process_intercept = 0
var timer_process = 0
var data = {}

var random_val = {}

var self_delta = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	data["hp"] = 0.0
	if not Engine.editor_hint:
		randomize()
		build_init_data()
		if active:
			set_physics_process(true)
		
	else:
		set_physics_process(false)
	pass # Replace with function body.

func set_param(key, val):
	data[key] = val
	
func start():
	active = true
	set_physics_process(active)
	
func stop():
	active = false
	set_physics_process(active)
	
func restart():
	active = true
	current = normal_start_name
	set_physics_process(active)
	
func create_resource():
	var data_ai = ResourceAIDiagram.new()
	data_ai.exterminate()
	datares = data_ai
	property_list_changed_notify()

func data_save(editor_panel):
	var gnodes = editor_panel.get_gnodes()
	var gconn = editor_panel.get_connection_list()
	var scroll_offset = editor_panel.get_scroll_offset()
	datares.update_resource_data(gnodes, gconn, scroll_offset)
	
func data_get():
	return datares

func build_init_data():
	for o in datares.get_gnodes():
		if o.type == "gn_entry":
			current = o.name
			normal_start_name = o.name
		if o.type == "gn_entry" or o.type == "gn_intercept" or o.type == "gn_exit" or o.type == "gn_process" or o.type == "gn_if_pcs" or o.type == "gn_random_selector" or o.type == "gn_process_intercept" or o.type == "gn_if_pcs_intercept" or o.type == "gn_random_selector_intercept":
			white_nodes[o.name] = o
			if o.type == "gn_intercept":
				intercept_current = o.name
				intercept_start_name = o.name
		else:
			red_nodes[o.name] = o
			
	for c in datares.get_connection():
		if conns.has(c.from):
			conns[c.from].append(c)
		else:
			conns[c.from] = []
			conns[c.from].append(c)
	
	
		
func _physics_process(delta):
	self_delta = delta
	if current != prev:
		_first = true
	else:
		_first = false
		
	if intercept_current != intercept_prev:
		_first_intercept = true
	else:
		_first_intercept = false
	
	### INTERCEPT
	if intercept_start_name != "":
		var intercept_state = white_nodes[intercept_current]
		match intercept_state.type:
			"gn_intercept":
				var evaluate_stmt = []
				for i in range(intercept_state.slot_count):
					var key = "slot_" + str(i)
					evaluate_stmt.append(intercept_state[key])
				gn_intercept_evaluate(evaluate_stmt)
			
			"gn_exit_intercept":
				intercept_next = intercept_start_name
				intercept_prev = intercept_current
				intercept_current = intercept_next
				
			"gn_process_intercept":
				if intercept_prev != intercept_current:
					if intercept_state.runtype == "Timer-Float":
						timer_process_intercept = float(intercept_state.runlength)
					else:
						timer_process_intercept = data[intercept_state.runlength]
					
				for o in conns[intercept_current]:
					if o.from_port > 0:
						pcs_red_node(o.to)
						
				timer_process_intercept -= delta
				if timer_process_intercept <= 0:
					var find = false
					for o in conns[intercept_current]:
						if o.from_port == 0:
							intercept_next = o.to
							find = true
					if find:
						intercept_prev = intercept_current
						intercept_current = intercept_next
					else:
						intercept_next = intercept_start_name
						intercept_prev = intercept_current
						intercept_current = intercept_next
				else:
					intercept_prev = intercept_current
					
				
			
					
			"gn_random_selector_intercept":
				pcs_random_selector_intercept(intercept_state)
			
			"gn_if_pcs_intercept":
				var evaluate_stmt = []
				for i in range(intercept_state.slot_count):
					var key = "slot_" + str(i)
					evaluate_stmt.append(intercept_state[key])
				pcs_if_evaluate_intercept(evaluate_stmt)
		
		if intercept_current != intercept_start_name:
			return
		
	### NORMAL STATE
	var state = white_nodes[current]
	match state.type:
		"gn_entry":
			for o in conns[current]:
				next = o.to
			prev = current
			current = next
		"gn_process":
			#print(state.process)
			if prev != current:
				if state.runtype == "Timer-Float":
					timer_process = float(state.runlength)
				else:
					#print(data)
					timer_process = float(data[state.runlength])
				
			for o in conns[current]:
				if o.from_port > 0:
					pcs_red_node(o.to)
					
			if state.chk_break:
				var ret = checK_process_condition_break(state.break_condition)
				if ret:
					timer_process = 0
					#print("break")
					
			timer_process -= delta
			if timer_process <= 0:
				var find = false
				for o in conns[current]:
					if o.from_port == 0:
						next = o.to
						find = true
				if find:
					prev = current
					current = next
				else:
					next = normal_start_name
					prev = current
					current = next
			else:
				prev = current
				
		"gn_if_pcs":
			var evaluate_stmt = []
			for i in range(state.slot_count):
				var key = "slot_" + str(i)
				evaluate_stmt.append(state[key])
			pcs_if_evaluate(evaluate_stmt)
			
		"gn_random_selector":
			pcs_random_selector(state)
			
		"gn_exit":
				next = normal_start_name
				prev = current
				current = next
	
	
func pcs_red_node(node_name):
	var substate = red_nodes[node_name]
	match substate.type:
		"gn_rand_val":
			pcs_rand_val(substate)
		"gn_func":
			pcs_func(substate)
		"gn_set_value":
			pcs_set_value(substate)
		"gn_math":
			pcs_math(substate)
			
func pcs_rand_val(substate):
	var ret
	match substate.datatype:
		"Float":
			ret = rand_range(float(substate.min1), float(substate.max1))
		"Integer":
			ret = floor( rand_range(float(substate.min1), float(substate.max1) + 0.99) )
		"Vector2":
			var x = rand_range(float(substate.min1), float(substate.max1))
			var y = rand_range(float(substate.min2), float(substate.max2))
			ret = Vector2(x, y)
			if substate.normalized:
				ret = ret.normalized()
		"Vector3":
			var x = rand_range(float(substate.min1), float(substate.max1))
			var y = rand_range(float(substate.min2), float(substate.max2))
			var z = rand_range(float(substate.min3), float(substate.max3))
			ret = Vector3(x, y, z)
			if substate.normalized:
				ret = ret.normalized()
	data[substate.result] = ret

func pcs_func(substate):
	var ret
	var param = {}
	param["_delta"] = self_delta
	param["_first"] = _first
	param["_first_intercept"] = _first_intercept
	if substate.slot_count > 0:
		for i in range(substate.slot_count):
			var key = "slot_" + str(i)
			var param_data = substate[key]
			var param_idx = i
			match param_data.datatype:
				"Bool":
					if param_data.value == "true":
						param[param_idx] = true
					else:
						param[param_idx] = false
				"Integer":
					param[param_idx] = int(param_data.value)
				"Float":
					param[param_idx] = float(param_data.value)
				"String":
					param[param_idx] = str(param_data.value)
				"Variable":
					param[param_idx] = data[param_data.value]
	if substate.return == "":
		get_parent().call(substate.func, param)
	else:
		#print(substate.return)
		data[str(substate.return)] = get_parent().call(substate.func, param)
	#print(data)
	
func pcs_set_value(substate):
	var param_data = substate.value
	match param_data.datatype:
		"Bool":
			if param_data.value == "true":
				data[substate.var] = true
			else:
				data[substate.var] = false
		"Integer":
			data[substate.var] = int(param_data.value)
		"Float":
			data[substate.var] = float(param_data.value)
		"String":
			data[substate.var] = str(param_data.value)
		"Variable":
			data[substate.var] = data[param_data.value]
		"Vector2":
			var val_str = param_data.value
			val_str = val_str.split(",")
			data[substate.var] = Vector2(float(val_str[0]), float(val_str[1]))
		"Vector3":
			var val_str = param_data.value
			val_str = val_str.split(",")
			data[substate.var] = Vector3(float(val_str[0]), float(val_str[1]), float(val_str[2]))
			

func pcs_math(substate):
	
	var right
	match substate.datatype:
		"Int":
			right = int(substate.value)
		"Float":
			right = float(substate.value)
		"Variable":
			right = data[substate.value]
		"Delta":
			right = self_delta
	
	match substate.operator:
		"+=":
			data[substate.result] += right
		"-=":
			data[substate.result] -= right
		"*=":
			data[substate.result] *= right
		"/=":
			data[substate.result] /= right
	

func pcs_if_evaluate(evaluate_stmt):
	
	var ret = false
	for e in evaluate_stmt:
		var right
		match e.datatype:
			"bool":
				if e.right == "true":
					right = true
				else:
					right = false
			"int":
				right = int(e.right)
			"float":
				right = float(e.right)
			"string":
				right = str(e.right)
			"variable":
				right = data[e.right]
				
		match e.operator:
			"=":
				if data[e.left] == right:
					ret = true
			"<":
				if data[e.left] < right:
					ret = true
			">":
				if data[e.left] > right:
					ret = true
			"<=":
				if data[e.left] <= right:
					ret = true
			">=":
				if data[e.left] >= right:
					ret = true
		if ret:
			for o in conns[current]:
				if o.from_port == e.conn_port:
					next = o.to
					prev = current
					current = next
					return
	if not ret:
		for o in conns[current]:
			if o.from_port == 0:
				next = o.to
				prev = current
				current = next

func pcs_random_selector(state):
	var accepted = false
	var chosen = 0
	
	chosen = floor(rand_range(0, float(state.slot_count) - 0.01) )
	if random_val.has(current):
		if random_val[current] == chosen:
			chosen += 1
			if chosen > state.slot_count-1:
				chosen = 0
	
	random_val[current] = chosen
	
	for o in conns[current]:
		if o.from_port == chosen:
			next = o.to
			prev = current
			current = next
		
func gn_intercept_evaluate(evaluate_stmt):
	
	var ret = false
	for e in evaluate_stmt:
		var right
		match e.datatype:
			"bool":
				if e.right == "true" or e.right == "1":
					right = true
				else:
					right = false
			"int":
				right = int(e.right)
			"float":
				right = float(e.right)
			"string":
				right = str(e.right)
			"variable":
				right = data[e.right]
		match e.operator:
			"=":
				if data[e.left] == right:
					ret = true
			"<":
				if data[e.left] < right:
					ret = true
			">":
				if data[e.left] > right:
					ret = true
			"<=":
				if data[e.left] <= right:
					ret = true
			">=":
				if data[e.left] >= right:
					ret = true
		if ret:
			for o in conns[intercept_current]:
				if o.from_port == e.conn_port:
					intercept_next = o.to
					intercept_prev = intercept_current
					intercept_current = intercept_next
					return
		
func pcs_random_selector_intercept(state):
	var chosen = floor(rand_range(0, float(state.slot_count) - 0.01) )
	for o in conns[intercept_current]:
		if o.from_port == chosen:
			intercept_next = o.to
			intercept_prev = intercept_current
			intercept_current = intercept_next

func pcs_if_evaluate_intercept(evaluate_stmt):
	
	var ret = false
	for e in evaluate_stmt:
		var right
		match e.datatype:
			"bool":
				if e.right == "true":
					right = true
				else:
					right = false
			"int":
				right = int(e.right)
			"float":
				right = float(e.right)
			"string":
				right = str(e.right)
			"variable":
				right = data[e.right]
				
		match e.operator:
			"=":
				if data[e.left] == right:
					ret = true
			"<":
				if data[e.left] < right:
					ret = true
			">":
				if data[e.left] > right:
					ret = true
			"<=":
				if data[e.left] <= right:
					ret = true
			">=":
				if data[e.left] >= right:
					ret = true
		if ret:
			for o in conns[intercept_current]:
				if o.from_port == e.conn_port:
					intercept_next = o.to
					intercept_prev = intercept_current
					intercept_current = intercept_next
					return
	if not ret:
		for o in conns[intercept_current]:
			if o.from_port == 0:
				intercept_next = o.to
				intercept_prev = intercept_current
				intercept_current = intercept_next

func checK_process_condition_break(e):
	var ret = false
	
	var right
	match e.datatype:
		"bool":
			if e.right == "true" or e.right == "1":
				right = true
			else:
				right = false
		"int":
			right = int(e.right)
		"float":
			right = float(e.right)
		"string":
			right = str(e.right)
		"variable":
			right = data[e.right]
				
	match e.operator:
		"=":
			if data[e.left] == right:
				ret = true
		"<":
			if data[e.left] < right:
				ret = true
		">":
			if data[e.left] > right:
				ret = true
		"<=":
			if data[e.left] <= right:
				ret = true
		">=":
			if data[e.left] >= right:
				ret = true
	return ret

func return_normal_state_to_beginning():
	prev = current
	next = normal_start_name
	current = next
