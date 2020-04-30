extends "res://creature.gd"

const monster_group = "monster"
const monster_spawn_group = "monster_spawn"

onready var bullet_scene = preload("res://bullet.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func set_selected(selected):
	if selected:
		$StaticUI/SelectBox.show()
	else:
		$StaticUI/SelectBox.hide()

func _physics_process(delta):
	_ally_physics_process(delta)
	
func _ally_physics_process(delta):
	_attack_closest_monster_in_range()
	_handle_health_bar()
	_handle_static_ui()
	move_along_path(delta)
	
func give_order(coordinate):
	update_path_to_coordinate(coordinate)

func _handle_static_ui():
	var su : Node2D = $StaticUI
	su.set_rotation(-rotation)
	su.set_global_position(global_position)
	
func _handle_health_bar():
	var hb : ProgressBar = $StaticUI/HealthBar
	hb.value = health
	hb.max_value = max_health
	

func _attack_closest_monster_in_range() -> void:
	var attack_timer : Timer = $AttackCooldown
	if attack_timer.time_left > 0:
		return
	var attack_area : Area2D = $AttackArea
	var nodes_in_range = attack_area.get_overlapping_bodies()
	var target_node = null
	var shortest_distance = -1
	for node in nodes_in_range:
		if (node.is_in_group(monster_group) and !node.is_dead) or node.is_in_group(monster_spawn_group):
			$CanSeeRay.look_at(node.global_position)
			$CanSeeRay.force_raycast_update()
			var cast_object = $CanSeeRay.get_collider()
			if cast_object == node || (cast_object && (cast_object.is_in_group(monster_group) or cast_object.is_in_group(monster_spawn_group))):
				if target_node == null:
					target_node = cast_object
					shortest_distance = global_position.distance_to(target_node.global_position)
				elif global_position.distance_to(cast_object.global_position) < shortest_distance:
					target_node = cast_object
					shortest_distance = global_position.distance_to(target_node.global_position)
				
				
	if target_node != null:
		look_at(target_node.global_position)
		attack_timer.start()
		$AnimationPlayer.play("attack")
		var gun_end : Position2D = $Hands/Gun/GunEnd
		_fire_bullet_on_vector(gun_end.global_position, gun_end.global_position.direction_to(target_node.global_position))
	elif nav_path.size() > 1:	#else look at where you're going
		look_at(nav_path[1])
		
			
			
func _fire_bullet_on_vector(start_position: Vector2, direction: Vector2):
	var b = bullet_scene.instance()
	b.set_direction(direction)
	b.global_position = start_position
	get_node("/root/Game").add_projectile(b)

func die():
	var allies = get_tree().get_nodes_in_group("ally")
	if allies.size() == 1 and allies[0] == self:
		get_node("/root/Game").end_game()	
	.die()
	
	
