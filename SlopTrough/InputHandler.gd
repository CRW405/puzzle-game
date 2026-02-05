## InputHandler - User Input Processing
##
## Handles mouse and keyboard input for placing/removing elements.
## Converts screen coordinates to grid coordinates and paints in a circular brush pattern.
##
## Controls:
## - Number keys 1-3: Select element type (Wall, Sand, Water)
## - Left Mouse: Place selected element
## - Right Mouse: Erase elements (place EMPTY)
##
## The circular brush creates a natural-feeling painting tool.

extends Node
class_name InputHandler

# Reference to the simulation (for placing elements)
var simulation: Simulation

# Size of each pixel in the grid (for coordinate conversion)
var pixel_scale: int

# Radius of the circular brush in cells
var brush_size: int

# Parent node (used to get mouse position)
var parent: Node2D

# Currently selected element type to place
var current_element: int = ElementTypes.SAND

## Initializes the input handler
func initialize(sim: Simulation, scale: int, brush: int, p: Node2D):
	simulation = sim    # Reference to simulation for placing cells
	pixel_scale = scale # Tile size for coordinate conversion
	brush_size = brush  # Brush radius in cells
	parent = p          # Parent node for mouse position

## Processes user input each frame
## Called from the main game loop
func handle_input():
	# Number keys switch between element types
	# These check if the key is currently pressed (not just pressed this frame)
	if Input.is_key_pressed(KEY_1):
		current_element = ElementTypes.WALL
	elif Input.is_key_pressed(KEY_2):
		current_element = ElementTypes.SAND
	elif Input.is_key_pressed(KEY_3):
		current_element = ElementTypes.WATER
	
	# Left click places the current element
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		# Get mouse position in world space
		var mouse_pos = parent.get_global_mouse_position()
		# Convert pixel coordinates to grid coordinates
		var grid_x = int(mouse_pos.x / pixel_scale)
		var grid_y = int(mouse_pos.y / pixel_scale)
		# Place cells in a circular brush pattern
		place_cells(grid_x, grid_y, current_element)
	
	# Right click erases (places EMPTY)
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		var mouse_pos = parent.get_global_mouse_position()
		var grid_x = int(mouse_pos.x / pixel_scale)
		var grid_y = int(mouse_pos.y / pixel_scale)
		place_cells(grid_x, grid_y, ElementTypes.EMPTY)

## Places cells in a circular brush pattern around the center point
## This creates a natural painting effect rather than placing single cells
func place_cells(center_x: int, center_y: int, cell_type):
	# Scan a square region around the center
	for y in range(center_y - brush_size, center_y + brush_size + 1):
		for x in range(center_x - brush_size, center_x + brush_size + 1):
			# Calculate distance from center
			var dist = Vector2(x - center_x, y - center_y).length()
			# Only place if within circular radius
			# This creates a circular brush instead of a square one
			if dist <= brush_size:
				simulation.set_cell(x, y, cell_type)

## Returns the currently selected element type
## Used by UI to display what you're placing
func get_current_element() -> int:
	return current_element

