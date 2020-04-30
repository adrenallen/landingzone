extends Node2D

export var _placement_active = false

const allowed_placement_color = Color(0.46, 1, 0.46)
const restricted_placement_color = Color(1, 0.46, 0.46)

signal item_used #emitted when this item has been fully used

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_placement_active(active):
	_placement_active = active

func _physics_process(delta):
	if _placement_active:
		update_preview(delta)

func update_preview(delta):
	print("Update preview should be implemented in child...")
	get_tree().quit()

func item_placed():
	emit_signal("item_used")
