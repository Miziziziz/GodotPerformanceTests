extends Spatial


var dist_in_range = 3

var agents = []
func _ready():
	yield(get_tree(), "idle_frame")
	agents = get_tree().get_nodes_in_group("wander_agents")
	agents.erase(get_parent())

func _process(delta):
	var our_pos = global_transform.origin
	var others_in_range = false
	for agent in agents:
		var their_pos = agent.global_transform.origin
		if our_pos.distance_squared_to(their_pos) < dist_in_range*dist_in_range:
			others_in_range = true
			break
	
	if others_in_range:
		$Red.show()
		$Yellow.hide()
	else:
		$Red.hide()
		$Yellow.show()

func disable():
	set_process(false)
	set_physics_process(false)
	hide()
