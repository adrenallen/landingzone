extends Node2D


const speed = 450.0
const dest_proximity = 10

enum ON_ARRIVAL{
	land,
	exit
}

var destination = Vector2.ZERO
var on_dest_arrival = ON_ARRIVAL.land

var is_flying = true
var occupants = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	if !is_flying:
		_attempt_loading()
	else:
		global_position = global_position.move_toward(destination, speed*delta)
		_rotate_towards(destination)
	
	if global_position.distance_to(destination) < dest_proximity:
		_arrive_at_destination()

func _arrive_at_destination():
	match on_dest_arrival:
		ON_ARRIVAL.land:
			_land()
			return
		ON_ARRIVAL.exit:
			_exit_map()
			return

func _rotate_towards(pos):
	look_at(pos)

func takeoff_and_exit(coords):
	on_dest_arrival = ON_ARRIVAL.exit
	destination = coords
	takeoff()

func takeoff():
	$LandPlayer.play("takeoff")
	
func _takeoff_complete():
	is_flying = true
	
func _fly_to_helipad():
	pass

func _exit_map():
	print("Saved ", occupants, " civilians!")
	get_node("/root/Game").saved_civilians += occupants
	get_node("/root/Game/HelicopterDelayTimer").start()
	queue_free()

func _land():
	destination = Vector2.ZERO
	is_flying = false
	$LandPlayer.play("land")
	
func _attempt_loading():
	var save_bodies = $PickupArea.get_overlapping_bodies()
	for node in save_bodies:
		if node.is_in_group("saveme"):
			node.queue_free()
			occupants += 1
