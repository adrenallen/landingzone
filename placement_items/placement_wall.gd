extends "res://placement_items/placement_tiles.gd"

func _ready():
	item_tiles = [
		ItemTile.new(0,0,5),
		ItemTile.new(2,-2,5),
		ItemTile.new(1,-1,5),
		ItemTile.new(-1,-1,5),
		ItemTile.new(-2,-2,5),
	]	

