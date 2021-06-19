extends Area


export var use_signals = false
var cache = {}

var alternate_frames = true
var a_frame = false

func _ready():
	a_frame = randi() % 2 == 0

	yield(get_tree(), "idle_frame")
	if use_signals:
		connect("body_entered", self, "on_body_enter")
		connect("body_exited", self, "on_body_exit")
		set_physics_process(false)
		set_process(false)

func _physics_process(delta):
	if get_overlapping_bodies().size() > 1:
		$Red.show()
		$Yellow.hide()
	else:
		$Red.hide()
		$Yellow.show()

func on_body_enter(body: PhysicsBody):
	cache[body.get_path()] = ""
	update_visuals_from_cache()

func on_body_exit(body: PhysicsBody):
	cache.erase(body.get_path())
	update_visuals_from_cache()

func update_visuals_from_cache():
	if cache.size() > 0:
		$Red.show()
		$Yellow.hide()
	else:
		$Red.hide()
		$Yellow.show()

