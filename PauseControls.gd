extends Camera2D

var dragging = false  # Are we currently dragging?
var selected = []  # Array of selected units.
var drag_start = Vector2.ZERO  # Location where drag began.
var select_rect = RectangleShape2D.new()  # Collision shape for drag box.
var camera_dragging = false
export var camera_drag_dampen = 30
const max_zoom = 3.0
const min_zoom = 0.7
const zoom_rate = 0.2
var camera_zoom = 1

const camera_max_pos = Vector2(2500,2500)
const camera_min_pos = Vector2(-2500, -2500)

func _ready():
	$Control/ControlScale/SendOrdersButton.connect("pressed", self, "_send_commands")
	$LiveMode/AnnouncementTimer.connect("timeout", self, "_announcement_timeout")

func _process(delta):
	if get_node("/root/Game").command_mode_active:
		$Control.visible = true
		$LiveMode.visible = false
		_draw_box()
		update()
	else:
		$Control.visible = false
		$LiveMode.visible = true
		$LiveMode/LiveModeScale/Countdown.text = "Communications In\n" + str(round(get_node("/root/Game/CommandModeTimer").time_left)) + " seconds"
		dragging = false
		selected = []
	
func _update_zoom():
	$Control/ControlScale.scale = Vector2(camera_zoom, camera_zoom)
	$LiveMode/LiveModeScale.scale = Vector2(camera_zoom, camera_zoom)
	zoom = Vector2(camera_zoom, camera_zoom)
		
		
func _physics_process(delta):
	if camera_dragging:
		var move_to_amt = (get_local_mouse_position() - drag_start)
		move_to_amt /= camera_drag_dampen
		global_position -= move_to_amt
	if global_position.x < camera_min_pos.x:
		global_position.x = camera_min_pos.x
	if global_position.x > camera_max_pos.x:
		global_position.x = camera_max_pos.x
	if global_position.y < camera_min_pos.y:
		global_position.y = camera_min_pos.y
	if global_position.y > camera_max_pos.y:
		global_position.y = camera_max_pos.y

func _send_commands():
	get_node("/root/Game").set_command_mode(false)
	_unselect_all()
	update()

func _unselect_all():
	for node in selected:
		node.set_selected(false)
	selected = []

func show_announcement(text, time = 5):
	$LiveMode/LiveModeScale/AnnouncementLabel.text = text
	$LiveMode/LiveModeScale/AnnouncementLabel.visible = true
	if time > 0:
		$LiveMode/AnnouncementTimer.start(time)
	
func _announcement_timeout():
	$LiveMode/LiveModeScale/AnnouncementLabel.text = ""
	$LiveMode/LiveModeScale/AnnouncementLabel.visible = false
	
# handles selecting units and drag of camera
func _unhandled_input(event):
	if get_node("/root/Game").command_mode_active:
		if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
			if event.pressed:
				# We only want to start a drag if there's no selection.
				if selected.size() == 0 || Input.is_action_pressed("control"):
					dragging = true
					drag_start = event.position * zoom
				else:
					var avg_pos = Vector2(0,0)
					for node in selected:
						avg_pos += node.global_position
					avg_pos = avg_pos/selected.size()
					for node in selected:
						node.give_order((event.position * zoom) + global_position + (node.global_position - avg_pos))
						print(event.position)
					update()
					_unselect_all()
			elif dragging:
				if !Input.is_action_pressed("control"):
					_unselect_all()
				dragging = false
				update()
				var drag_end = event.position * zoom
				select_rect.extents = (drag_end - drag_start) / 2
				var space = get_world_2d().direct_space_state
				var query = Physics2DShapeQueryParameters.new()
				query.set_shape(select_rect)
				query.transform = Transform2D(0, ((drag_end + drag_start) / 2) + global_position)
				var intersected_shapes = space.intersect_shape(query)
				for shape in intersected_shapes:
					if shape.collider.is_in_group("selectable"):
						shape.collider.set_selected(true)
						selected.append(shape.collider)
			
			if event is InputEventMouseMotion and dragging:
				update()
	
	if (event is InputEventMouseButton and (event.button_index == BUTTON_MIDDLE or (event.button_index == BUTTON_LEFT and Input.is_action_pressed("ctrl")))):
		if event.pressed:
			camera_dragging = true
			drag_start = event.position * zoom
		elif camera_dragging:
			camera_dragging = false
	
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == BUTTON_WHEEL_DOWN:
			camera_zoom += zoom_rate
			if camera_zoom > max_zoom:
				camera_zoom = max_zoom
		if event.button_index == BUTTON_WHEEL_UP:
			camera_zoom -= zoom_rate
			if camera_zoom < min_zoom:
				camera_zoom = min_zoom
		
		if event.button_index == BUTTON_WHEEL_UP or event.button_index == BUTTON_WHEEL_DOWN:
			_update_zoom()
				
	
	
# Draw the select box
func _draw_box():
	if dragging:
		var sb : Panel = $Control/SelectBox
		sb.visible = true
		sb.rect_position = drag_start
		var size = get_local_mouse_position() - drag_start
		if size.x < 0:
			size.x = abs(size.x)
			sb.rect_scale.x = -1
		else: 
			sb.rect_scale.x = 1
		if size.y < 0:
			size.y = abs(size.y)
			sb.rect_scale.y = -1
		else: 
			sb.rect_scale.y = 1
		sb.rect_size = size
	else:
		$Control/SelectBox.visible = false

# Draws the nav path and dots!
func _draw():
	if get_node("/root/Game").command_mode_active:
		var color = Color.green
		color.a = 0.5
		for node in get_tree().get_nodes_in_group("selectable"):
			if node.nav_path.size() > 0:
				for i in range(1, node.nav_path.size()):
					draw_line(node.nav_path[i-1] - global_position, node.nav_path[i] - global_position, color, 3.0 / zoom.x)
				draw_circle(node.nav_path[node.nav_path.size()-1] - global_position, 12.0 / zoom.x, color)
