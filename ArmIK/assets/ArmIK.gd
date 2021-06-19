extends Spatial

onready var hand_r = $HandR
onready var hand_l = $HandL

export(NodePath) var magnet_l_path
export(NodePath) var magnet_r_path

var magnet_l : Spatial
var magnet_r : Spatial

export(NodePath) var hand_l_path
export(NodePath) var hand_r_path

var ref_hand_r : Spatial
var ref_hand_l : Spatial

export(NodePath) var skeleton_path
onready var skeleton : Skeleton = get_node(skeleton_path)

var upper_arm_l_ind = 0
var lower_arm_l_ind = 0
var hand_l_ind = 0
var upper_arm_r_ind = 0
var lower_arm_r_ind = 0
var hand_r_ind = 0

var arm_upper_length_l = 0.0
var arm_lower_length_l = 0.0
var arm_upper_length_r = 0.0
var arm_lower_length_r = 0.0

func _ready():
	magnet_l = get_node(magnet_l_path)
	magnet_r = get_node(magnet_r_path)
	ref_hand_r = get_node(hand_r_path)
	ref_hand_l = get_node(hand_l_path)
	
	upper_arm_l_ind = skeleton.find_bone("arm_upperl")
	lower_arm_l_ind = skeleton.find_bone("arm_lowerl")
	hand_l_ind = skeleton.find_bone("handl")
	upper_arm_r_ind = skeleton.find_bone("arm_upperr")
	lower_arm_r_ind = skeleton.find_bone("arm_lowerr")
	hand_r_ind = skeleton.find_bone("handr")
	if upper_arm_l_ind < 0: # for some reason after upgrading to 3.3 all newly imported models bones have a dot
		upper_arm_l_ind = skeleton.find_bone("arm_upper.l")
		lower_arm_l_ind = skeleton.find_bone("arm_lower.l")
		hand_l_ind = skeleton.find_bone("hand.l")
		upper_arm_r_ind = skeleton.find_bone("arm_upper.r")
		lower_arm_r_ind = skeleton.find_bone("arm_lower.r")
		hand_r_ind = skeleton.find_bone("hand.r")
	
	var shoulder_pos_l = skeleton.get_bone_global_pose(upper_arm_l_ind).origin
	var elbow_pos_l = skeleton.get_bone_global_pose(lower_arm_l_ind).origin
	var hand_pos_l = skeleton.get_bone_global_pose(hand_l_ind).origin
	var shoulder_pos_r = skeleton.get_bone_global_pose(upper_arm_r_ind).origin
	var elbow_pos_r = skeleton.get_bone_global_pose(lower_arm_r_ind).origin
	var hand_pos_r = skeleton.get_bone_global_pose(hand_r_ind).origin
	
	arm_upper_length_l = shoulder_pos_l.distance_to(elbow_pos_l)
	arm_lower_length_l = hand_pos_l.distance_to(elbow_pos_l)
	arm_upper_length_r = shoulder_pos_r.distance_to(elbow_pos_r)
	arm_lower_length_r = hand_pos_r.distance_to(elbow_pos_r)

func _process(_delta):
	update_hand_transforms()

func update_hand_transforms():
	if !is_instance_valid(ref_hand_l) or !is_instance_valid(ref_hand_r):
		return
	hand_r.global_transform = ref_hand_r.global_transform
	hand_l.global_transform = ref_hand_l.global_transform
	update_arm_transforms()

func update_arm_transforms():
	update_arm_transform(upper_arm_l_ind, lower_arm_l_ind, hand_l_ind, arm_upper_length_l, arm_lower_length_l, hand_l, magnet_l.global_transform.origin)
	update_arm_transform(upper_arm_r_ind, lower_arm_r_ind, hand_r_ind, arm_upper_length_r, arm_lower_length_r, hand_r, magnet_r.global_transform.origin, false)

func update_arm_transform(upper_arm_ind, lower_arm_ind, hand_ind, upper_arm_len, lower_arm_len, goal_hand, magnet_position, is_left=true):
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
	#$DebugPoint.transform.origin = new_hand_transform.origin
	

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

var cur_y_angle = 0.0
func update_turn_info(y_angle: float):
	cur_y_angle = y_angle

func enable():
	set_process(true)

func disable():
	set_process(false)
