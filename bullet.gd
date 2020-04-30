extends Node2D

var movement_vector = Vector2(1,0)
export var SPEED = 1800
export var damage = 20
export var team : String = "ally"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	global_position.x += SPEED * movement_vector.x * delta
	global_position.y += SPEED * movement_vector.y * delta
	
func set_direction(vector: Vector2):
	movement_vector = vector
	rotate(vector.angle())

# Nuke the bullet from the game after timeout
func _on_Timer_timeout():
	queue_free()

var has_damaged = false
func _on_Area2D_body_entered(body):
	if body.has_method("take_damage") and !body.is_in_group(team):
		if !has_damaged:
			has_damaged = true
			body.take_damage(damage)
		queue_free()
	elif body.is_in_group("projectile_wall"):
		queue_free()
