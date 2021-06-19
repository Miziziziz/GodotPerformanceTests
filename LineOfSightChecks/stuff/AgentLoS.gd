extends Spatial


var target : Spatial

var check_this_frame = true
var los = false

export var alternate_frames = false
var extra_times_to_run = 3

func _ready():
	target = get_tree().get_nodes_in_group("target")[0]
	check_this_frame = randi() % 2 == 0

func _process(_delta):
	var target_point = target.global_transform.origin
	if has_los(target_point):
		$Red.show()
		$Yellow.hide()
	else:
		$Red.hide()
		$Yellow.show()
	
	for _i in range(extra_times_to_run):
		has_los(target_point)

func has_los(point: Vector3):
	if alternate_frames:
		check_this_frame = !check_this_frame
		if !check_this_frame:
			return los
	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray(global_transform.origin, point, [], 1)
	if result:
		los = false
	else:
		los = true
	return los
