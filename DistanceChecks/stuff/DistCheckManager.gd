extends Spatial


var agents_to_coord_cache = {}
var world_cache = {}
var chunk_size = 5

func update_pos(agent: Spatial):
	var agent_key = str(agent)
	var new_coord = get_agent_coord_str(agent)
	
	# check if agent is still in the same chunk it was previously, if so return
	if agent_key in agents_to_coord_cache:
		var old_coord = agents_to_coord_cache[agent_key]
		if old_coord == new_coord:
			return
	
		# it's in a new chunk, remove it from the old chunk
		if old_coord in world_cache:
			world_cache[old_coord].erase(agent_key)
			# delete chunk if it's empty
			if world_cache[old_coord].size() == 0:
				world_cache.erase(old_coord)
	
	agents_to_coord_cache[agent_key] = new_coord
	
	#see if need to instance new chunk
	if !new_coord in world_cache:
		world_cache[new_coord] = {}
	
	world_cache[new_coord][agent_key] = agent


func get_agents_in_radius(agent: Spatial, dist_check_radius: float, verbose=false):
	var chunk_range_to_check = 1 + int(dist_check_radius/chunk_size)
	
	var agent_pos = agent.global_transform.origin
	var x = int(agent_pos.x / chunk_size)
	var z = int(agent_pos.z / chunk_size)
	
	var agents = []
	for i in range(x-chunk_range_to_check, x+chunk_range_to_check+1):
		for j in range(z-chunk_range_to_check, z+chunk_range_to_check+1):
			agents += get_agents_in_chunk("%d,%d" % [i, j])
	
	var agents_in_radius = []
	for a in agents:
		if a == agent:
			continue
		var a_pos = a.global_transform.origin
		if agent_pos.distance_squared_to(a_pos) < dist_check_radius * dist_check_radius:
			agents_in_radius.append(a)
	
	return agents_in_radius

func get_agents_in_chunk(coord: String):
	if coord in world_cache:
		return world_cache[coord].values()
	return []

func get_agent_coord_str(agent: Spatial):
	return get_coord_str(agent.global_transform.origin)

func get_coord_str(pos: Vector3):
	pos /= chunk_size
	var x = int(pos.x)
	var z = int(pos.z)
	return "%d,%d" % [x, z]
