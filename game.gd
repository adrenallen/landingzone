extends Node

# List of tiles allowed to be placed on
const allowed_placement_tiles = [
	4,
	2
]
var game_over = false

var zombie_spawn_scene = preload("res://enemies/ZombieSpawn.tscn")
var helicopter_scene = preload("res://helicopter.tscn")

var creature_kill_count = {}
var saved_civilians = 0

var current_item : Node = null
var store_item = null
var next_item = null

var nav_2d : Navigation2D setget set_nav_2d, get_nav_2d
var nav_obstacle_outlines = []
var command_mode_active = false

var can_call_helicopter = false
var can_evac_helicopter = false

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	$GameWorld/CivilianTimer.connect("timeout", self, "_civilian_timer_timeout")
	$GameWorld/ZombieNestTimer.connect("timeout", self, "_zombie_nest_timer_timeout")
	$PauseControls/Control/ControlScale/CallHeli.connect("pressed", self, "_spawn_helicopter")
	$PauseControls/Control/ControlScale/ReturnHeli.connect("pressed", self, "_return_helicopter")
	
	$ProjectileBlockingMap.visible = false
	# initialize our item options
	_get_next_item_from_provider()
	_tick_next_current_items()
	_init_projectile_map_for_world()
	$CommandModeTimer.start(5)
	
	
func _spawn_helicopter():
	$PauseControls/Control/ControlScale/CallHeli.visible = false
	var heli = helicopter_scene.instance()
	heli.global_position = $GameWorld/HelicopterEntrance.global_position
	heli.destination = $GameWorld/HelicopterLanding.global_position
	$GameWorld.add_child(heli)
	
func _return_helicopter():
	$PauseControls/Control/ControlScale/ReturnHeli.visible = false
	var helicopter_query = get_tree().get_nodes_in_group("helicopter")
	var heli = helicopter_query[0].takeoff_and_exit($GameWorld/HelicopterExit.global_position)

func _zombie_nest_timer_timeout():
	_spawn_zombie_nest()
	$GameWorld/ZombieNestTimer.start()
	
func _spawn_zombie_nest():
	
	if $GameWorld/ZombieSpawners.get_child_count() == $GameWorld/ZombieSpawnerLocations.get_child_count():
		return # already maxed
		
	var current_nest_locs = []
	for n in $GameWorld/ZombieSpawners.get_children():
		current_nest_locs.append(n.global_position)
	var spawn_loc = $GameWorld/ZombieSpawnerLocations.get_child(randi() % $GameWorld/ZombieSpawnerLocations.get_child_count()).global_position
	while current_nest_locs.has(spawn_loc):
		spawn_loc = $GameWorld/ZombieSpawnerLocations.get_child(randi() % $GameWorld/ZombieSpawnerLocations.get_child_count()).global_position
		print("had spawn loc")
	var spawn = zombie_spawn_scene.instance()
	spawn.global_position = spawn_loc
	$GameWorld/ZombieSpawners.add_child(spawn)
	spawn.look_at(Vector2(530,400))
	
	
	
func _civilian_timer_timeout():
	var city = $GameWorld/Cities.get_child(randi() % $GameWorld/Cities.get_child_count())
	city.spawn_civilians(1)
	$PauseControls.show_announcement("Civilians are escaping from " + city.city_name)
	$GameWorld/CivilianTimer.start()

func _init_projectile_map_for_world():
	var used_cells = $Navigation2D/WorldMap.get_used_cells()
	for cell_coords in used_cells:
		var starter_tile = obstacle_service.get_default_item_tile_for_map(cell_coords.x, cell_coords.y, $Navigation2D/WorldMap.get_cellv(cell_coords))
		obstacle_service.set_item_tile(starter_tile)

func _process(delta):
	if Input.is_action_just_pressed("store_item"):
		store_current_item()
	if Input.is_action_just_pressed("cancel_item"):
		_delete_placement_items()
		$PauseControls/Control/ControlScale/Items/CurrentItem.set_active(false)
		
	$PauseControls/LiveMode/LiveModeScale/ZombieKillCount.text = str(creature_kill_count.get("monster", 0))
	$PauseControls/LiveMode/LiveModeScale/CivilianSaveCount.text = str(saved_civilians)
func store_current_item():
	var temp = null
	if store_item != null:
		temp = store_item
	set_store_item(current_item)
	set_current_item(temp)
	$PauseControls/Control/ControlScale/Items/CurrentItem.set_active(false)
	
func set_current_item(item_node):
	if current_item:
		current_item.queue_free()
		_delete_placement_items()
	if item_node:
		current_item = item_node.duplicate()
	else:
		current_item = null
	get_node("/root/Game/PauseControls/Control/ControlScale/Items/CurrentItem").set_item(current_item)

func set_store_item(item_node):
	if store_item:
		store_item.queue_free()
	if item_node:
		store_item = item_node.duplicate()
	else:
		store_item = null
	get_node("/root/Game/PauseControls/Control/ControlScale/Items/StoreItem").set_item(store_item)
	
func set_next_item(item_node):
	if item_node:
		next_item = item_node.duplicate()
	else:
		next_item = null
	get_node("/root/Game/PauseControls/Control/ControlScale/Items/NextItem").set_item(next_item)

func _current_item_placed():
	set_current_item(null)
	$PauseControls/Control/ControlScale/Items/CurrentItem.set_active(false)
	

func set_command_mode(mode):
	command_mode_active = !command_mode_active
	get_tree().paused = command_mode_active
	if mode:
		can_evac_helicopter = false
		can_call_helicopter = false
		
		var helicopter_query = get_tree().get_nodes_in_group("helicopter")
		
		#can evac heli if it's landed 
		if helicopter_query.size() > 0 and !helicopter_query[0].is_flying:
			can_evac_helicopter = true
		
		#can only call helicopter if no heli present and timer is out
		if helicopter_query.size() == 0 and $HelicopterDelayTimer.time_left <= 0:
			can_call_helicopter = true
#		
		$PauseControls/Control/ControlScale/CallHeli.visible = can_call_helicopter
		$PauseControls/Control/ControlScale/ReturnHeli.visible = can_evac_helicopter
		
		if $GameWorld/ZombieSpawners.get_child_count() < 1:
			_spawn_zombie_nest()
	else:
		_delete_placement_items()
		$PauseControls/Control/ControlScale/Items/CurrentItem.set_active(false)
		$CommandModeTimer.start(15)
	
func set_nav_2d(nav: Navigation2D):
	nav_2d = nav
	
func get_nav_2d():
	if nav_2d == null:
		var nav_nodes = get_tree().get_nodes_in_group("nav_2d")
		if nav_nodes.size() > 0:
			set_nav_2d(nav_nodes[0])
	return nav_2d

func get_nav_path(fromPos: Vector2, toPos: Vector2) -> PoolVector2Array:
	nav_2d = get_nav_2d()
	if nav_2d == null:
		return PoolVector2Array()
	return nav_2d.get_simple_path(fromPos, toPos, false)

func _get_game_world() -> Node:
	var possible_nodes = get_tree().get_nodes_in_group("game_world")
	if possible_nodes.size() > 0:
		return possible_nodes[0]
	return null

func add_projectile(node: Node):
	var game_world = _get_game_world()
	if game_world == null:
		return
	game_world.get_node("Projectiles").add_child(node)

# Handles dropping current item and moving next
# then refilling next
func _tick_next_current_items():
	_move_next_to_current_item()
	_get_next_item_from_provider()

func _get_next_item_from_provider():
	set_next_item(item_provider.get_next_item())
	
func _move_next_to_current_item():
	set_current_item(null)
	set_current_item(next_item)
	

func _on_CommandModeTimer_timeout():
	set_command_mode(true)
	_tick_next_current_items()

func _on_CurrentItem_item_box_clicked():
	var current_item_box = $PauseControls/Control/ControlScale/Items/CurrentItem
	if current_item_box.is_active:
		_delete_placement_items()
		current_item_box.set_active(false)
	elif current_item != null:
		current_item_box.set_active(true)
		var pi_node = get_node("PauseControls/PlacementItem")
		var placement_item_node = current_item.duplicate()
		pi_node.add_child(placement_item_node)
		placement_item_node.set_placement_active(true)
		placement_item_node.connect("item_used", self, "_current_item_placed")
	
func _delete_placement_items():
	get_node("ItemPreviewMap").visible = false
	var pi_node = get_node("PauseControls/PlacementItem")
	for n in pi_node.get_children():
		n.set_placement_active(false)
		n.queue_free()
	
func record_creature_death(groups):
	for group in groups:
		if !creature_kill_count.has(group):
			creature_kill_count[group] = 1
		else:
			creature_kill_count[group] += 1
		
func end_game():
	$PauseControls.show_announcement("Game over!", -1)
	game_over = true
	get_tree().paused = true
