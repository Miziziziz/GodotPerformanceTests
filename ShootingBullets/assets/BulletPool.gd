extends Spatial


var bullet_obj = preload("res://ShootingBullets/assets/Bullet.tscn")
var bullet_pool_size = 200
var bullet_pool = []

var hit_effect_obj = preload("res://ShootingBullets/assets/HitEffect.tscn")
var hit_effect_pool_size = 200
var hit_effect_pool = []

func _ready():
	for _i in range(bullet_pool_size):
		spawn_bullet()
		spawn_hit_effect()

func spawn_bullet():
	var bullet_inst = bullet_obj.instance()
	bullet_inst.connect("hit_something", self, "reset_bullet", [bullet_inst])
	bullet_pool.append(bullet_inst)

func spawn_hit_effect():
	var hit_effect_inst = hit_effect_obj.instance()
	hit_effect_inst.connect("timed_out", self, "reset_hit_effect", [hit_effect_inst])
	hit_effect_pool.append(hit_effect_inst)

func get_bullet():
	if bullet_pool.size() == 0:
		spawn_bullet()
	return bullet_pool.pop_back()

func get_hit_effect():
	if hit_effect_pool.size() == 0:
		spawn_hit_effect()
	return hit_effect_pool.pop_back()

func reset_bullet(bullet_inst):
	if is_instance_valid(bullet_inst.get_parent()):
		bullet_inst.get_parent().remove_child(bullet_inst)
	bullet_pool.push_back(bullet_inst)

func reset_hit_effect(hit_effect_inst):
	if is_instance_valid(hit_effect_inst.get_parent()):
		hit_effect_inst.get_parent().remove_child(hit_effect_inst)
	hit_effect_pool.push_back(hit_effect_inst)
