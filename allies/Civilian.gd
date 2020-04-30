extends "res://ally.gd"


var soldier_follow = null # following a soldier


# Called when the node enters the scene tree for the first time.
func _ready():
	path_position_proximity = 5
	pass # Replace with function body.

func _physics_process(delta):
	pass

var random_distance_mod = randi() % 64 - 64
func _ally_physics_process(delta):
	_look_for_soldier_follow()
	move_along_path_and_look(delta)
	_handle_health_bar()
	_handle_static_ui()
	
func _look_for_soldier_follow():
	soldier_follow = false
	var nav_group_bodies = $FollowArea.get_overlapping_bodies()
	for node in nav_group_bodies:
		if node.is_in_group("followable_ally"):
			soldier_follow = true
			break
	
	if soldier_follow:
		add_to_group("selectable")
		$StaticUI.visible = true
	else:
		remove_from_group("selectable")
		$StaticUI.visible = false
		
	






# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
