extends Spatial

onready var hand_r = $HandR
onready var hand_l = $HandL

export(NodePath) var magnet_l_path
export(NodePath) var magnet_r_path

var magnet_l : Spatial
var magnet_r : Spatial

export(NodePath) var hand_l_path
export(NodePath) var hand_r_path

# use separate vars here which let's me swap out reference hands on the fly
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

var ik_manager

func _ready():
	ik_manager = get_tree().get_nodes_in_group("ik_manager")[0]
	
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
#	update_hand_transforms()
	ik_manager.queue_calc_ik(skeleton, upper_arm_l_ind, lower_arm_l_ind, hand_l_ind, arm_upper_length_l, arm_lower_length_l, hand_l, magnet_l.global_transform.origin, rotation.y, true)
	ik_manager.queue_calc_ik(skeleton, upper_arm_r_ind, lower_arm_r_ind, hand_r_ind, arm_upper_length_r, arm_lower_length_r, hand_r, magnet_r.global_transform.origin, rotation.y, false)

#func update_hand_transforms():
#	if !is_instance_valid(ref_hand_l) or !is_instance_valid(ref_hand_r):
#		return
#	hand_r.global_transform = ref_hand_r.global_transform
#	hand_l.global_transform = ref_hand_l.global_transform

