extends Spatial


var dist_check_manager
var dist_check_radius = 3

export var verbose = false

func _ready():
	var dist_check_managers = get_tree().get_nodes_in_group("dist_check_manager")
	if dist_check_managers.size() == 0:
		return
	dist_check_manager = dist_check_managers[0]

func _process(delta):
	if !is_instance_valid(dist_check_manager):
		return
	dist_check_manager.update_pos(self)
	var agents = dist_check_manager.get_agents_in_radius(self, dist_check_radius, verbose)
	if agents.size() > 0:
		$Red.show()
		$Yellow.hide()
	else:
		$Red.hide()
		$Yellow.show()
