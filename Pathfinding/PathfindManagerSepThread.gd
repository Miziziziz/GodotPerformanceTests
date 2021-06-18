extends Spatial

var nav : Navigation

var paths_to_calc_queue = []
var completed_path_calcs = []
var cache = {}

var path_calc_thread: Thread = Thread.new()
var mutex : Mutex = Mutex.new()

func _ready():
	nav = get_tree().get_nodes_in_group("navigation")[0]

func _process(delta):
	if completed_path_calcs.size() > 0:
		mutex.lock()
		for completed_path_calc in completed_path_calcs:
			completed_path_calc.agent.update_path(completed_path_calc.path)
		completed_path_calcs = []
		mutex.unlock()
	
	if !path_calc_thread.is_active() and paths_to_calc_queue.size() > 0:
		path_calc_thread.start(self, "do_path_calcs")

func calc_path(start_pos: Vector3, end_pos: Vector3, agent: QueueAgent):
	var key = str(agent)
	if key in cache:
		return
	var calc_info = {
		"agent": agent,
		"start_pos": start_pos,
		"end_pos": end_pos,
	}
	mutex.lock()
	cache[key] = ""
	paths_to_calc_queue.push_back(calc_info)
	mutex.unlock()

func do_path_calcs(params):
	while paths_to_calc_queue.size() > 0:
		complete_path_calc()
	path_calc_thread.call_deferred("wait_to_finish")

func complete_path_calc():
	if paths_to_calc_queue.size() == 0:
		return
	
	var calc_info = paths_to_calc_queue[0]
	var new_path = nav.get_simple_path(calc_info.start_pos, calc_info.end_pos)
	var agent : QueueAgent = calc_info.agent
	
	mutex.lock()
	completed_path_calcs.push_back({
		"agent": agent,
		"path": new_path
		})
	cache.erase(str(agent))
	paths_to_calc_queue.pop_front()
	mutex.unlock()
