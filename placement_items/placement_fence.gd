extends "res://placement_items/placement_tiles.gd"
const tile_health = 60
func _ready():
	item_tiles = [
		ItemTile.new(0,0,1),
		ItemTile.new(1,0,1),
		ItemTile.new(-1,0,1),
		ItemTile.new(2,0,1),
		ItemTile.new(-2,0,1),
	]	

