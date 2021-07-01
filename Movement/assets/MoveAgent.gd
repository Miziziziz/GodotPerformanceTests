extends KinematicBody

var move_speed = 10
var gravity = 10.0
var velocity = Vector3()

enum MOVE_MODES {MOVE_AND_COLLIDE, MOVE_AND_SLIDE, MOVE_AND_SLIDE_AND_SNAP, TIME_SPLICED}
export(MOVE_MODES) var cur_move_mode = MOVE_MODES.MOVE_AND_COLLIDE

func _physics_process(delta):
	var move_vec = Vector3.RIGHT
	
	var grav_vec = Vector3.DOWN * gravity * delta
	if is_on_floor():
		grav_vec = Vector3.ZERO
		velocity.y = 0.01
	
	var drag_vec = Vector3(velocity.x * 0.9, 0.0, velocity.z * 0.9)
	
	velocity += move_vec * move_speed - drag_vec + grav_vec
	
	match cur_move_mode:
		MOVE_MODES.MOVE_AND_COLLIDE:
			move_and_collide(velocity * delta)
		MOVE_MODES.MOVE_AND_SLIDE:
			move_and_slide(velocity, Vector3.UP)
		MOVE_MODES.MOVE_AND_SLIDE_AND_SNAP:
			move_and_slide_with_snap(velocity, Vector3.DOWN, Vector3.UP)
		MOVE_MODES.TIME_SPLICED:
			move_time_spliced(velocity, Vector3.UP)


var move_group = 0
var num_of_move_groups = 3
var start_pos : Vector3
var end_pos : Vector3
var first_run = true
func _ready():
	move_group = randi() % num_of_move_groups

func move_time_spliced(velo, up_vec):
	move_group += 1
	move_group %= num_of_move_groups
	if move_group == 0:
		start_pos = global_transform.origin
		move_and_slide(velo * num_of_move_groups, up_vec)
		end_pos = global_transform.origin
		first_run = false
	if !first_run:
		var t = (move_group+1.0)/num_of_move_groups
		global_transform.origin = start_pos.linear_interpolate(end_pos, t)
