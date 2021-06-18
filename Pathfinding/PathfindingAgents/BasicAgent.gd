extends Spatial


var nav : Navigation
var target : Spatial
var path = []

var move_speed = 10.0

func _ready():
	nav = get_tree().get_nodes_in_group("navigation")[0]
	target = get_tree().get_nodes_in_group("target")[0]

func _process(delta):
	path = nav.get_simple_path(global_transform.origin, target.global_transform.origin)

func _physics_process(delta):
	if path.size() > 1:
		var dir : Vector3 = path[1] - global_transform.origin
		dir.y = 0
		dir = dir.normalized()
		global_translate(dir * move_speed * delta)
