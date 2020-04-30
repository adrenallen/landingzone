extends "res://placement_item.gd"

var ItemTile = load("res://item_tile.gd")

onready var preview_map : TileMap = get_tree().get_root().get_node("/root/Game/ItemPreviewMap")
onready var world_map : TileMap = get_tree().get_root().get_node("/root/Game/Navigation2D/WorldMap")
onready var projectile_map : TileMap = get_tree().get_root().get_node("/root/Game/ProjectileBlockingMap")

const helipad_box = {
	"min": Vector2(16,10),
	"max": Vector2(25,19)
}

var placement_allowed = false

var item_tiles = [
	ItemTile.new(0,0,1, 20),
	ItemTile.new(2,0,1, 20),
	ItemTile.new(1,0,1, 20),
	ItemTile.new(-1,0,1, 20),
	ItemTile.new(-2,0,1, 20)
]

var item_tile_origin : Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Updates the placement preview!
func update_preview(delta):
	if Input.is_action_just_pressed("rotate"):
		_rotate_tiles()
	var mouse_pos := get_global_mouse_position()
	var current_tile_pos = preview_map.world_to_map(mouse_pos)
	if current_tile_pos != item_tile_origin:
		item_tile_origin = current_tile_pos
		_update_preview_map()
		
	if Input.is_action_just_pressed("place_item") and placement_allowed:
		on_place()

func _rotate_tiles():
	for item_tile in item_tiles:
		item_tile.rotate()
	item_tile_origin = Vector2.ZERO # to force an update
	
# updates the placement preview map
func _update_preview_map():
	preview_map.visible = true
	preview_map.clear()
	for item_tile in item_tiles:
		preview_map.set_cellv(item_tile_origin + item_tile.position, item_tile.tile_idx, item_tile.get_flip_x(), item_tile.get_flip_y(), item_tile.get_transpose())
	_update_placement_allowed()


#updates placement allowed variable if allowed
func _update_placement_allowed():
#	print(get_local_mouse_position()) # TODO - this can eb used to disable place over buttons in the future
	placement_allowed = true
	for item_tile in item_tiles:
		var coords = item_tile_origin + item_tile.position
		var current_tile = world_map.get_cellv(coords)
		if current_tile != item_tile.tile_idx and not get_node("/root/Game").allowed_placement_tiles.has(current_tile):
			placement_allowed = false
			break
		if _coords_inside_helipad(coords):
			placement_allowed = false
			break
	
	if placement_allowed:
		preview_map.modulate = allowed_placement_color
	else:
		preview_map.modulate = restricted_placement_color
	
func _coords_inside_helipad(coords: Vector2) -> bool:
	if coords.x >= helipad_box["min"].x && coords.x <= helipad_box["max"].x:
		if coords.y >= helipad_box["min"].y && coords.y <= helipad_box["max"].y:
			return true
	return false
	
	
func on_place():
	for item_tile in item_tiles:
		var global_item_tile = item_tile
		global_item_tile.position += item_tile_origin
		obstacle_service.set_item_tile(global_item_tile)
#		world_map.set_cellv(item_tile_origin + item_tile.position, item_tile.tile_idx, item_tile.get_flip_x(), item_tile.get_flip_y(), item_tile.get_transpose())
#		if item_tile.projectile_blocking:
#			projectile_map.set_cellv(item_tile_origin + item_tile.position, item_tile.tile_idx, item_tile.get_flip_x(), item_tile.get_flip_y(), item_tile.get_transpose())
			
	item_placed()
