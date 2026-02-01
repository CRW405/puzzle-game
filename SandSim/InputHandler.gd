extends Node
class_name InputHandler

var simulation: Simulation
var pixel_scale: int
var brush_size: int
var parent: Node2D
var current_element: int = ElementTypes.SAND

func initialize(sim: Simulation, scale: int, brush: int, p: Node2D):
	simulation = sim
	pixel_scale = scale
	brush_size = brush
	parent = p

func handle_input():
	# Number keys to switch elements
	if Input.is_key_pressed(KEY_1):
		current_element = ElementTypes.WALL
	elif Input.is_key_pressed(KEY_2):
		current_element = ElementTypes.SAND
	elif Input.is_key_pressed(KEY_3):
		current_element = ElementTypes.WATER
	
	# Left click to place current element
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var mouse_pos = parent.get_global_mouse_position()
		var grid_x = int(mouse_pos.x / pixel_scale)
		var grid_y = int(mouse_pos.y / pixel_scale)
		place_cells(grid_x, grid_y, current_element)
	
	# Right click to delete
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		var mouse_pos = parent.get_global_mouse_position()
		var grid_x = int(mouse_pos.x / pixel_scale)
		var grid_y = int(mouse_pos.y / pixel_scale)
		place_cells(grid_x, grid_y, ElementTypes.EMPTY)

func place_cells(center_x: int, center_y: int, cell_type):
	for y in range(center_y - brush_size, center_y + brush_size + 1):
		for x in range(center_x - brush_size, center_x + brush_size + 1):
			var dist = Vector2(x - center_x, y - center_y).length()
			if dist <= brush_size:
				simulation.set_cell(x, y, cell_type)

func get_current_element() -> int:
	return current_element

