extends Spatial

class_name QueueAgent

var target : Spatial
var pathfind_manager
var path = []

var move_speed = 10.0

func _ready():
	target = get_tree().get_nodes_in_group("target")[0]
	pathfind_manager = get_tree().get_nodes_in_group("pathfind_manager")[0]

func _process(delta):
	pathfind_manager.calc_path(global_transform.origin, target.global_transform.origin, self)

func _physics_process(delta):
	if path.size() > 1:
		var dir : Vector3 = path[1] - global_transform.origin
		dir.y = 0
		dir = dir.normalized()
		global_translate(dir * move_speed * delta)

func update_path(new_path: Array):
	path = new_path
