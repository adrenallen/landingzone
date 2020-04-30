extends Camera2D
var dragging = false
var drag_start := Vector2(0,0)
export var move_dampen = 30
func _unhandled_input(event):
	if (event is InputEventMouseButton and (event.button_index == BUTTON_MIDDLE or (event.button_index == BUTTON_LEFT and Input.is_action_pressed("ctrl")))):
		if event.pressed:
			dragging = true
			drag_start = event.position 
		elif dragging:
			dragging = false
			
func _process(delta):
	if dragging:
		var move_to_amt = (get_viewport().get_mouse_position() - drag_start)
		move_to_amt /= move_dampen
		global_position += move_to_amt
