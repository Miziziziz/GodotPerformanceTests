extends KinematicBody


var move_speed = 3
var move_vec : Vector3

var dist_check_radius = 4

func _ready():
	move_vec = Vector3.RIGHT.rotated(Vector3.UP, rand_range(0.0, TAU))
	move_vec.y = 0

func _physics_process(delta):
	var coll = move_and_collide(move_speed * delta * move_vec)
	if coll:
		var d = move_vec
		var n = coll.normal
		var r = d - 2 * d.dot(n) * n
		move_vec = r
		move_vec.y = 0
