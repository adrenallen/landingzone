extends StaticBody2D

export var health = 1000
var is_destroyed = false
var nav_polygon_idx : int = -1


# Called when the node enters the scene tree for the first time.
func _ready():
	var col_polygon = $NavigationPolygon2D.get_polygon()
	print(col_polygon)
	var nav_polygon := PoolVector2Array()
	for vector in col_polygon:
		
		nav_polygon.append(vector.rotated(rotation) + global_position)
		
	nav_polygon_idx = get_node("/root/Game").add_nav_poly(nav_polygon)

func take_damage(dmg: int) -> void:
	if !is_destroyed:
		health -= dmg
		if health <= 0:
			_destroy()

func _destroy() -> void:
	is_destroyed = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
