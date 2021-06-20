extends Spatial


var bullet_obj = preload("res://ShootingBullets/assets/Bullet.tscn")


var fire_rate = 0.02
var cur_fire_time = 0.0

func _process(delta):
	cur_fire_time += delta
	if cur_fire_time >= fire_rate:
		fire()
		cur_fire_time = 0.0

func fire():
	var bullet_inst = bullet_obj.instance()
	bullet_inst.global_transform = global_transform
	bullet_inst.connect("hit_something", bullet_inst, "queue_free")
	get_parent().add_child(bullet_inst)
