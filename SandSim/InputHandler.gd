## UserInput
extends Node
class_name InputHandler

## Setup
var sim: Simulation
var scale: int
var brush_size: int
var parent: Node2D
var current_element: int


func init(simulation: Simulation, pixel_scale: int, brush: int, p: Node2D):
	sim = simulation
	scale = pixel_scale
	brush_size = brush
	parent = p


func handle_input():
	if Input.is_key_pressed(KEY_1):
		current_element = Registry.WALL
	elif Input.is_key_pressed(KEY_2):
		current_element = Registry.SAND
	elif Input.is_key_pressed(KEY_3)
		current_element = Registry.WATER

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var pos = parent.get_global_mouse_position()
		var grid_x = int(pos.x / scale)
		var grid_y = int(pos.y / scale)

		place(grid_x, grid_y)


func place(grid_x, grid_y):
	for y in range(grid_y - brush_size, grid_y + brush_size + 1):
		for x in range(grid_x - brush_size, grid_x + brush_size + 1):
			var distance Vector2(x - grid_x, y - grid_y).length()
			if distance <= brush_size:
				sim.set(x,y, current_element)
