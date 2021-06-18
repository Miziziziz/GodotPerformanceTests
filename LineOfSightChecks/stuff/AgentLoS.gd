extends Spatial


var target : Spatial

func _ready():
	target = get_tree().get_nodes_in_group("target")[0]

func _process(_delta):
	var target_point = target.global_transform.origin
	if has_los(target_point):
		$Red.show()
		$Yellow.hide()
	else:
		$Red.hide()
		$Yellow.show()

func has_los(point: Vector3):
	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray(global_transform.origin, point, [], 1)
	if result:
		return false
	return true
