extends KinematicBody2D

var bullet_i = preload("res://demo/bullet.tscn")
var speed = 1200
var velocity = Vector2()
onready var sprite = $tank
var rotation_speed = 10
onready var bullet_origin = $tank/bullet_origin
var dir = Vector2()
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func move(p):
	var delta = p["_delta"]
	dir = p[0]
	speed = p[1]
	velocity = dir * speed * delta
	var _vel = move_and_slide(velocity)
	
	#rotate_sprite
	sprite.rotation = lerp_angle(sprite.rotation, dir.angle(), rotation_speed * delta)
	
func shoot(_p):
	var o = bullet_i.instance()
	get_parent().add_child(o)
	o.start(bullet_origin.global_position, dir)
	
