extends Spatial

var speed = 100.0
signal hit_something

var last_pos : Vector3
var use_pool_for_hit_effect = false

func _ready():
	last_pos = global_transform.origin
	$HitEffectSpawner.use_pool_for_hit_effect = use_pool_for_hit_effect

func init():
	$HitTimer.start()

func _physics_process(delta):
	translate_object_local(Vector3.FORWARD*delta*speed)
	var cur_pos = global_transform.origin
	
	var space_state = get_world().get_direct_space_state()
	var result = space_state.intersect_ray(last_pos, cur_pos, [], 1)
	if result:
		$HitEffectSpawner.spawn_hit_effect(result.position, result.normal)
		hit_something()
	last_pos = cur_pos

func hit_something():
	$HitTimer.stop()
	emit_signal("hit_something")
