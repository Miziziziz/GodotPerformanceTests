extends Spatial

var radius = 4

var frame = 0
var frame_to_run_on = 0
var frame_cycle = 2

func _ready():
	frame_to_run_on = randi() % frame_cycle

func _physics_process(delta):
	frame += 1
	frame %= 4
	if frame != frame_to_run_on:
		return
	update_stuff()

func update_stuff():
	var query = PhysicsShapeQueryParameters.new()
	var select_transform = Transform()
	select_transform.origin = global_transform.origin
	query.set_transform(select_transform)
	var circle_shape = SphereShape.new()
	circle_shape.radius = radius
	query.set_shape(circle_shape)
	query.collision_mask = 2
	var space_state = get_world().get_direct_space_state()
	var results = space_state.intersect_shape(query)
	if results.size() > 1:
		$Red.show()
		$Yellow.hide()
	else:
		$Red.hide()
		$Yellow.show()

#	var objects = []
#	for item_data in result:
#		objects.append(item_data.collider)
#	return objects
