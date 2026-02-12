## UserInput
extends Node
class_name InputHandler

## Setup
var sim: Simulation
var scale: int
var brush_size: int
var parent: Node2D
var current_element: int = 2


func initialize(simulation: Simulation, pixel_scale: int, brush: int, p: Node2D):
	sim = simulation
	scale = pixel_scale
	brush_size = brush
	parent = p


func handle_input():
	if Input.is_key_pressed(KEY_1):
		current_element = Registry.elements.WALL
	elif Input.is_key_pressed(KEY_2):
		current_element = Registry.elements.SAND
	elif Input.is_key_pressed(KEY_3):
		current_element = Registry.elements.WATER
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var pos = parent.get_global_mouse_position()
		var matrix_x = int(pos.x / scale)
		var matrix_y = int(pos.y / scale)

		place(matrix_x, matrix_y)


func place(matrix_x, matrix_y):
	if brush_size == 1:
		sim.set_cell(matrix_x, matrix_y, current_element)
		return

	for y in range(matrix_y - brush_size, matrix_y + brush_size + 1):
		for x in range(matrix_x - brush_size, matrix_x + brush_size + 1):
			var distance = Vector2(x - matrix_x, y - matrix_y).length()
			if distance <= brush_size:
				sim.set_cell(x, y, current_element)
