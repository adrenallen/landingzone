extends Node

var ItemTile = load("res://item_tile.gd")

var tiles = {}

var projectile_map : TileMap
var world_map : TileMap
const percent_to_show_damage = 0.5

const default_tile_health = {
	
}

func set_item_tile(item_tile : ItemTile):
	tiles[item_tile.position] = item_tile
	_get_world_map().set_cellv(item_tile.position, item_tile.tile_idx, item_tile.get_flip_x(), item_tile.get_flip_y(), item_tile.get_transpose())
	if item_tile.projectile_blocking:
		_get_projectile_map().set_cellv(item_tile.position, item_tile.tile_idx, item_tile.get_flip_x(), item_tile.get_flip_y(), item_tile.get_transpose())

func damage_tile(coords, dmg):
	if tiles.has(coords):
		if !tiles[coords].is_damaged and tiles[coords].health < tiles[coords].full_health * percent_to_show_damage:
			_make_tile_damaged(coords)
		tiles[coords].health -= dmg
		if tiles[coords].health <= 0:
			destroy_tile(coords)
	
func destroy_tile(coords):
	tiles.erase(coords)
	_get_world_map().set_cellv(coords, 2)
	_get_projectile_map().set_cellv(coords, -1)

func _get_projectile_map():
	if projectile_map == null:
		projectile_map = get_node("/root/Game/ProjectileBlockingMap")
	return projectile_map
	
func _get_world_map():
	if world_map == null:
		world_map = get_node("/root/Game/Navigation2D/WorldMap")
	return world_map
	
func get_default_item_tile_for_map(x, y, tile_idx) -> ItemTile:
	return ItemTile.new(x, y, tile_idx)

func _make_tile_damaged(coords: Vector2):
	var item_tile = tiles.get(coords)
	if item_tile:
		tiles[coords].is_damaged = true
		_get_world_map().set_cellv(item_tile.position, item_tile.get_damaged_tile_idx(), item_tile.get_flip_x(), item_tile.get_flip_y(), item_tile.get_transpose())
		if item_tile.projectile_blocking:
			_get_projectile_map().set_cellv(item_tile.position, item_tile.get_damaged_tile_idx(), item_tile.get_flip_x(), item_tile.get_flip_y(), item_tile.get_transpose())
	
	
