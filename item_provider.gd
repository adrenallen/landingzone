extends Node

onready var item_drop_options = [
	ItemDrop.new(preload("res://placement_items/placement_fence.tscn"), 0.5),
	ItemDrop.new(preload("res://placement_items/placement_wall.tscn"), 0.5)
]

var item_drop_history = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func get_next_item() -> Node:
	# TODO - randomly pick something
	var idx = randi() % item_drop_options.size()
	print(item_drop_options[idx].chance)
	item_drop_history.append(item_drop_options[idx])
	return item_drop_options[idx].item_scene.instance()

class ItemDrop:
	var item_scene : Resource = null
	var chance : float = 0.0
	var id : String = ""
	func _init(item_scene, chance):
		self.item_scene = item_scene
		self.chance = chance
		self.id = item_scene.get_path()
