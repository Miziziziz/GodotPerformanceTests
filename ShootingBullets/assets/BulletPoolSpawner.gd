extends Spatial


var bullet_pool
func _ready():
	bullet_pool = get_tree().get_nodes_in_group("bullet_pool")[0]

var fire_rate = 0.02
var cur_fire_time = 0.0

func _process(delta):
	cur_fire_time += delta
	if cur_fire_time >= fire_rate:
		fire()
		cur_fire_time = 0.0

func fire():
	var bullet_inst = bullet_pool.get_bullet()
	bullet_inst.global_transform = global_transform
	get_parent().add_child(bullet_inst)
	bullet_inst.init()
