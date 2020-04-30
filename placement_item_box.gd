extends Node2D

signal item_box_clicked

var item_type = null

export var is_active : bool = false
export var can_be_active : bool = false

const item_node_name = "item"

var has_item = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if !can_be_active:
		self.modulate = Color(0.8,0.8,0.8)
		$Button.set_button_mask(0) #ignore clicks
		$Button.mouse_filter = Control.MOUSE_FILTER_IGNORE
		$Button.mouse_default_cursor_shape = Control.CURSOR_ARROW
	
func set_item(item_node):
	_remove_current_item()
	if item_node != null:
		$item.add_child(item_node)
		has_item = true
		
func _remove_current_item():
	has_item = false
	for n in $item.get_children():
		n.queue_free()

func set_active(active):
	is_active = active
	$Button.disabled = is_active

func _on_Button_pressed():
	if can_be_active:
		emit_signal("item_box_clicked")
