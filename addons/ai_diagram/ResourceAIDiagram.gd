tool
extends Resource

class_name ResourceAIDiagram

var scroll_offset = Vector2()
var graph_nodes = []
var connections = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func exterminate():
	scroll_offset = Vector2()
	graph_nodes.clear()
	connections.clear()

func update_resource_data(pgnodes, pgconn, poffset):
	scroll_offset = poffset
	graph_nodes.clear()
	connections.clear()
	graph_nodes = pgnodes
	connections = pgconn

func get_scroll_offset():
	return scroll_offset
	
func get_gnodes():
	return graph_nodes
	
func get_connection():
	return connections

func _get_property_list():
	var _properties = []
	_properties.append(
	{
		"name":"scroll_offset",
		"type":TYPE_VECTOR2,
		"usage":PROPERTY_USAGE_NOEDITOR | PROPERTY_USAGE_SCRIPT_VARIABLE,
	})
	_properties.append(
	{
		"name":"graph_nodes",
		"type":TYPE_ARRAY,
		"usage":PROPERTY_USAGE_NOEDITOR | PROPERTY_USAGE_SCRIPT_VARIABLE,
	})
	_properties.append(
	{
		"name":"connections",
		"type":TYPE_ARRAY,
		"usage":PROPERTY_USAGE_NOEDITOR | PROPERTY_USAGE_SCRIPT_VARIABLE,
	})
	return _properties
