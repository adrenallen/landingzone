extends "res://creature.gd"

const nav_distance_update_rate = 5
const nav_update_rate = 0.5
const nav_follow_update_rate = 1
const ally_group = "ally"

const skip_leader_points_count = 5

export var is_nav_group_leader = false

var nav_group_leader = null

func _ready():
	var nav_timer : Timer = $UpdateNavTimer
	nav_timer.connect("timeout", self, "_update_pathfinding")
	nav_timer.start(randf()*1+nav_update_rate)
	$GatherFollowersTimeout.connect("timeout", self, "_gather_followers")
	if is_nav_group_leader:
		_become_group_leader()

func _physics_process(delta):
#	update_path_to_node(get_nearest_target())
	move_along_path_and_look(delta)
	_attack_first_ally_in_range()
	_try_attack_obstacles()
	
func _try_attack_obstacles():
	var attack_timer : Timer = $AttackCooldown
	if attack_timer.time_left <= 0:
		for i in get_slide_count():
			var collision = get_slide_collision(i)
			
			var pbm : TileMap = get_node("/root/Game/ProjectileBlockingMap")
			var tile_coords = pbm.world_to_map(collision.position)
			tile_coords -= collision.get_normal()
			tile_coords.x = round(tile_coords.x)
			tile_coords.y = round(tile_coords.y)
			obstacle_service.damage_tile(tile_coords, obstacle_damage)
			attack_timer.start()
			$AnimationPlayer.play("attack")
			

func _gather_followers():
	_become_group_leader()

func _update_pathfinding():
	if nav_group_leader and is_instance_valid(nav_group_leader):
		if nav_group_leader.nav_path.size() > 5:
			nav_path = nav_group_leader.nav_path
			nav_path.invert()
			nav_path.resize(nav_path.size()-2)
			nav_path.invert()
		else:
			#Else just dive at enemy? Maybe update this
			update_path_to_node(get_nearest_target())
	elif is_nav_group_leader:
		handle_nav_leader_updates()
	else:
		var target = get_nearest_target()
		nav_path = PoolVector2Array([global_position])
		if target != null:
			nav_path.append(target.global_position)
		
		
func handle_nav_leader_updates():
	if nav_path.size() < 20:
		print("Quick nav updates!")
		$UpdateNavTimer.start(nav_update_rate)
	else:
		print("Slow updates")
		$UpdateNavTimer.start(nav_distance_update_rate)
	
	update_path_to_node(get_nearest_target())
	_become_group_leader()

func _become_group_leader():
	is_nav_group_leader = true
	var nav_group_bodies = $NavGroupArea.get_overlapping_bodies()
	for node in nav_group_bodies:
		if node == self:
			print("skip self looking for nav followers")
			continue
		if node.is_in_group("monster") and !node.is_nav_group_leader:
			node.follow_friend(self)
	$GatherFollowersTimeout.start()

func follow_friend(friend_node):
	is_nav_group_leader = false
	nav_group_leader = friend_node
	nav_path = friend_node.nav_path
	$UpdateNavTimer.start(nav_follow_update_rate)

func get_nearest_target() -> Node2D:
	return get_nearest_node_in_group(ally_group)
	
func _attack_first_ally_in_range() -> void:
	var attack_timer : Timer = $AttackCooldown
	if attack_timer.time_left > 0:
		return
	var attack_area : Area2D = $AttackArea
	var nodes_in_range = attack_area.get_overlapping_bodies()
	for node in nodes_in_range:
		if node.is_in_group(ally_group) and !node.is_dead:
			var is_killed = node.take_damage(attack_damage)
			attack_timer.start()
			$AnimationPlayer.play("attack")
			if is_killed:
				handle_killed_target()
			return

# Current target killed so update nav
func handle_killed_target():
	if is_nav_group_leader:
		_update_pathfinding()
	elif nav_group_leader and is_instance_valid(nav_group_leader):
		nav_group_leader.handle_killed_target()
		
			
