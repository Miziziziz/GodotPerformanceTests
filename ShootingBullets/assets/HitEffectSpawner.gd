extends Spatial

var hit_effect_obj = preload("res://ShootingBullets/assets/HitEffect.tscn")
var use_pool_for_hit_effect = false

var hit_effect_pool
func _ready():
	if use_pool_for_hit_effect:
		hit_effect_pool = get_tree().get_nodes_in_group("bullet_pool")[0]

func spawn_hit_effect(pos: Vector3, normal: Vector3):
	var hit_effect_inst
	if !use_pool_for_hit_effect:
		hit_effect_inst = hit_effect_obj.instance()
	else:
		hit_effect_inst = hit_effect_pool.get_hit_effect()
	hit_effect_inst.global_transform = get_transform_from_hit_data(pos, normal)
	get_tree().get_root().add_child(hit_effect_inst)
	hit_effect_inst.init()

func get_transform_from_hit_data(pos: Vector3, dir: Vector3):
	var trans = Transform.IDENTITY
	trans.origin = pos
	if dir.angle_to(Vector3.UP) < 0.00005:
		pass
	elif dir.angle_to(Vector3.DOWN) < 0.00005:
		trans = trans.rotated(Vector3.RIGHT, PI)
	else:
		var y = dir.normalized()
		var x = y.cross(Vector3.UP).normalized()
		var z = x.cross(y).normalized()
		trans.basis = Basis(x, y, z)
	return trans
