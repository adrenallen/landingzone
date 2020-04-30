class_name ItemTile

var position : Vector2
var tile_idx : int
var rotations := 0 #how many times rotated
var projectile_blocking = false
var health = 20
var full_health = 20
var is_damaged = false
func _init(x, y, idx, health = 0, projectile_blocking = null):
	
	if health == 0:
		health = _get_default_health_by_tile(idx)
	
	if projectile_blocking == null:
		projectile_blocking = _get_default_blocking_by_tile(idx)
	
	position = Vector2(x,y)
	tile_idx = idx
	self.health = health
	self.full_health = health
	self.projectile_blocking = projectile_blocking
	
func rotate():
	position = Vector2(-position.y, position.x)
	rotations += 1
	rotations = rotations%4
	
func get_transpose() -> bool:
	return rotations == 1 or rotations == 3

func get_flip_y() -> bool:
	return rotations == 2
	
func get_flip_x() -> bool:
	return rotations == 3

func get_damaged_tile_idx() -> int:
	match tile_idx:
		1:
			return 7
		5: 
			return 6
	return tile_idx

func _get_default_health_by_tile(tile_idx) -> int:
	match tile_idx:
		1:
			return 150
		5:
			return 300
	return 50

func _get_default_blocking_by_tile(tile_idx) -> bool:
	match tile_idx:
		5:
			return true
	return false
