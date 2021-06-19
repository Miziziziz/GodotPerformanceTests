extends Spatial

var queue = []
var cache = {}


export var ik_calculations_per_frame = 4

func _process(delta):
	for _i in range(ik_calculations_per_frame):
		dequeue_ik_calc()


func get_key(skeleton: Skeleton, is_left):
	var key = str(skeleton)
	if is_left:
		key += "L"
	else:
		key += "R"
	return key

func queue_calc_ik(skeleton: Skeleton, upper_arm_ind, lower_arm_ind, hand_ind, upper_arm_len, lower_arm_len, goal_hand, magnet_position, cur_y_angle, is_left=true):
	var key = get_key(skeleton, is_left)
	if key in cache: 
		return
	
	cache[key] = ""
	var ik_data = {
		"skeleton": skeleton,
		"upper_arm_ind": upper_arm_ind,
		"lower_arm_ind": lower_arm_ind,
		"hand_ind": hand_ind,
		"upper_arm_len": upper_arm_len,
		"lower_arm_len": lower_arm_len,
		"goal_hand": goal_hand,
		"magnet_position": magnet_position,
		"cur_y_angle": cur_y_angle,
		"is_left": is_left,
	}
	queue.push_back(ik_data)

func dequeue_ik_calc():
	if queue.size() == 0:
		return
	var ik_data = queue.pop_front()
	calc_ik(ik_data.skeleton, 
		ik_data.upper_arm_ind, 
		ik_data.lower_arm_ind, 
		ik_data.hand_ind, 
		ik_data.upper_arm_len, 
		ik_data.lower_arm_len, 
		ik_data.goal_hand, 
		ik_data.magnet_position, 
		ik_data.cur_y_angle, 
		ik_data.is_left
	)
	var key = get_key(ik_data.skeleton, ik_data.is_left)
	cache.erase(key)

func calc_ik(skeleton: Skeleton, upper_arm_ind, lower_arm_ind, hand_ind, upper_arm_len, lower_arm_len, goal_hand, magnet_position, cur_y_angle, is_left):
	if !is_instance_valid(skeleton):
		return
	
	# bunch of math for doing IK on the arms
	var shoulder_pos = skeleton.get_bone_global_pose(upper_arm_ind).origin
	var goal_hand_pos = skeleton.to_local(goal_hand.global_transform.origin)
	var dis_from_shoulder_to_goal_pos = shoulder_pos.distance_to(goal_hand_pos)
	var angles = SSS_calc(upper_arm_len, lower_arm_len, dis_from_shoulder_to_goal_pos)
	var y = shoulder_pos.direction_to(goal_hand_pos)
	var tmp_z = shoulder_pos.direction_to(skeleton.to_local(magnet_position))
	var x = -y.cross(tmp_z).normalized()
	var z = x.cross(y).normalized()
	
	if !is_left and dis_from_shoulder_to_goal_pos > upper_arm_len + lower_arm_len:
		angles.B = PI # makes so arm points towards hand
	
	var angle = angles.B
	if angle != 0 and is_left:
		angle = PI - angle
	if !is_left:
		x = -x
		z = -z
		angle = -(PI - angle)
	
	y = y.rotated(x, angle)
	z = z.rotated(x, angle)
	
	var upper_arm_y = y
	
	#arm will point along y of basis, bicep faces towards z, x is towards inside
	var new_upper_arm_transform = Transform()
	new_upper_arm_transform.basis = Basis(z, y, -x)
	new_upper_arm_transform.origin = shoulder_pos
	new_upper_arm_transform.scaled(skeleton.scale)
	skeleton.set_bone_global_pose_override(upper_arm_ind, new_upper_arm_transform, 1, true)
	
	var new_lower_arm_transform = Transform()
	#var elbow_pos = skeleton.get_bone_global_pose(lower_arm_ind).origin

	if is_left:
		angle = PI - angles.C
	else:
		var tmp = y
		y = z
		z = -tmp
		angle = -3*PI/2 + angles.C
	
	y = -y.rotated(x, angle).normalized()
	z = -z.rotated(x, angle)
	
	if is_left:
		var t = clamp(cur_y_angle/90, 0.0, 1.0)
		z = z.rotated(y, -t * deg2rad(30))
		x = x.rotated(y, -t * deg2rad(30))
	
	new_lower_arm_transform.basis = Basis(z, y, -x)
	new_lower_arm_transform.origin = shoulder_pos + upper_arm_y * upper_arm_len
	skeleton.set_bone_global_pose_override(lower_arm_ind, new_lower_arm_transform, 1, true)
	
	var new_hand_transform = Transform()
	var hand_global_pos = goal_hand.global_transform.origin
	new_hand_transform.origin = goal_hand_pos
	var t_x = skeleton.to_local(hand_global_pos + goal_hand.global_transform.basis.x)
	var t_y = skeleton.to_local(hand_global_pos + goal_hand.global_transform.basis.y)
	var t_z = skeleton.to_local(hand_global_pos + goal_hand.global_transform.basis.z)
	t_x = t_x - goal_hand_pos
	t_y = t_y - goal_hand_pos
	t_z = t_z - goal_hand_pos
	if is_left:
		new_hand_transform.basis = Basis(t_x, t_z, -t_y)
	else:
		new_hand_transform.basis = Basis(t_x, -t_z, t_y)
	skeleton.set_bone_global_pose_override(hand_ind, new_hand_transform, 1, true)
	

func SSS_calc(side_a, side_b, side_c):
	if side_c >= side_a + side_b:
		return {"A": 0, "B": 0, "C": 0}
	var angle_a = law_of_cos(side_b, side_c, side_a)
	var angle_b = law_of_cos(side_c, side_a, side_b) + PI
	var angle_c = PI - angle_a - angle_b
	
	return {"A": angle_a, "B": angle_b, "C": angle_c}

func law_of_cos(a, b, c):
	if 2 * a * b == 0:
		return 0
	return acos( (a * a + b * b - c * c) / ( 2 * a * b) )
