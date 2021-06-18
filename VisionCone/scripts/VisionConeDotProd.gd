extends Spatial



export var times_to_run = 1000
export var vision_cone_arc = 0.8

var target : Spatial

func _ready():
	target = get_tree().get_nodes_in_group("target")[0]

func _process(_delta):
	var target_point = target.global_transform.origin
	if in_vision_cone(target_point):
		$Red.show()
		$Yellow.hide()
	else:
		$Red.hide()
		$Yellow.show()
	
	for _i in range(times_to_run):
		in_vision_cone(target_point)

func in_vision_cone(point: Vector3):
	var fwd = -global_transform.basis.z
	var our_pos = global_transform.origin
	var dir_to_point = our_pos.direction_to(point)
	return dir_to_point.dot(fwd) > vision_cone_arc
