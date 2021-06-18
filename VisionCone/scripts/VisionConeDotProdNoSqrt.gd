extends Spatial


export var times_to_run = 1000

export var vision_cone_arc = 60
var sight_vectors = []

var target : Spatial


func _ready():
	target = get_tree().get_nodes_in_group("target")[0]
	
	var angle = deg2rad(90 - vision_cone_arc/2.0)
	sight_vectors.append(Vector3.FORWARD.rotated(Vector3.UP, angle))
	sight_vectors.append(Vector3.FORWARD.rotated(Vector3.UP, -angle))
	
	# comment these lines out if you only want a 2d vision cone (vision prism?)
	sight_vectors.append(Vector3.FORWARD.rotated(Vector3.RIGHT, angle))
	sight_vectors.append(Vector3.FORWARD.rotated(Vector3.RIGHT, -angle))

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
	var l_p = to_local(point)
	
	for s_v in sight_vectors:
		if s_v.dot(l_p) < 0:
			return false
	return true
