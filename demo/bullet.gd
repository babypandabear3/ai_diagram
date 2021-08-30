extends Area2D

var speed = 100
var dir = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func start(p_pos, p_dir):
	global_position = p_pos
	dir = p_dir
	
func _physics_process(delta):
	var move = dir * 100 * delta
	global_position += move
	
