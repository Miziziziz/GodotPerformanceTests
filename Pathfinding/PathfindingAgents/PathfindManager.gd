extends Spatial

var nav : Navigation

var queue = []
var cache = {}

func _ready():
	nav = get_tree().get_nodes_in_group("navigation")[0]

func _process(delta):
	if queue.size() > 0:
		var calc_info = queue.pop_front()
		var new_path = nav.get_simple_path(calc_info.start_pos, calc_info.end_pos)
		var agent : QueueAgent = calc_info.agent
		agent.update_path(new_path)
		cache.erase(str(agent))

func calc_path(start_pos: Vector3, end_pos: Vector3, agent: QueueAgent):
	var key = str(agent)
	if key in cache:
		return
	cache[key] = ""
	var calc_info = {
		"agent": agent,
		"start_pos": start_pos,
		"end_pos": end_pos,
	}
	queue.append(calc_info)
