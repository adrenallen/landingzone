extends KinematicBody2D

export var max_health = 100
var health = 100
export var speed : int  = 100
export var path_position_proximity = 2 # distance at which we are "close enough" to a node in the nav_path
export var attack_damage = 5
export var obstacle_damage = 5
var is_dead = false
var nav_path = []


# Called when the node enters the scene tree for the first time.
func _ready():
	health = max_health
	pass # Replace with function body.

# Returns true if the creature dies
func take_damage(dmg) -> bool:
	if is_dead:
		return false
	health -= dmg
	if health <= 0:
		die()
		return true
	return false
		
func get_nearest_node_in_group(group: String) -> Node2D:
	var check_nodes := get_tree().get_nodes_in_group(group)
	if check_nodes.size() < 1:
		return null
	var nearest_node = check_nodes[0]
	for check_node in check_nodes:
		#TODO - can make this faster by saving lowest distance number
		if self.global_position.distance_to(check_node.global_position) < self.global_position.distance_to(nearest_node.global_position):
			nearest_node = check_node
	return nearest_node

func update_path_to_node(target: Node2D) -> void:
	if target == null:
		nav_path = []
	else:
		update_path_to_coordinate(target.global_position)
	
func update_path_to_coordinate(coordinate: Vector2) -> void:
	set_nav_path(get_node("/root/Game").get_nav_path(self.global_position, coordinate))

func move_along_path_and_look(delta):
	move_along_path(delta)
	if nav_path.size() > 1:
		look_at(nav_path[1])

func set_nav_path(path) -> void:
	nav_path = path
	
func move_along_path(delta):
	if nav_path.size() > 1:
		var direction = global_position.direction_to(nav_path[1])
		var distance : Vector2 = global_position - nav_path[1]
#		var direction := distance.normalized()
		if distance.length() > path_position_proximity or nav_path.size() > 1:
#			look_at(nav_path[1])
			move_and_slide(direction*speed)
		if distance.length() < path_position_proximity:
			nav_path.remove(0)
		update()
	
func die():
	get_node("/root/Game").record_creature_death(get_groups())
	is_dead = true
	print("" + self.name + " is dead")
	queue_free()
