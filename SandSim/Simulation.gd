## main physics driver, 
## stores and performs actions on the matrix

class_name Simulation
extends Node

## Setup
var matrix: PackedInt32Array = PackedInt32Array()
var matrix_width: int
var matrix_height: int
var sim_steps: int
var cell_count: int = 0
var dirty_cells: Dictionary = {}  # Tracks cells that changed for dirty rendering

#...


func initialize(width: int, height: int):
	matrix_width = width
	matrix_height = height
	matrix.resize(matrix_width * matrix_height)
	matrix.fill(Registry.elements.EMPTY)


## Move the sim forward, physics update
func stepAll():
	# Cache registry lookups
	var unmoving = Registry.UNMOVING
	var moving = Registry.MOVING
	
	# alternates start for more natual looking physics 
	var start_y = matrix_height - 2 if sim_steps % 2 == 0 else matrix_height - 1

	# process bottom to top so we dont get weird gravity
	for y in range(start_y, -1, -1):
		## more alternation, in conjuction with the alternating y, 
		## we get a checkerboard pattern which helps to make the physics 
		## seem a little more natural and less 'stilted'
		var left_to_right = (y + sim_steps) % 2 == 0
		var start_x = 0 if left_to_right else matrix_width - 1
		var end_x = matrix_width if left_to_right else -1
		var step_x = 1 if left_to_right else -1

		for x in range(start_x, end_x, step_x):
			var cell = matrix[y * matrix_width + x]
	
			# unmoving elements do not need to be processed
			if cell in unmoving:
				continue
			
			if cell in moving:
				Registry.get_behaviour(cell, matrix, x, y, matrix_width, matrix_height)
	
	## Merge all dirties with new dirties
	dirty_cells.merge(Util.dirty_cells)
	Util.dirty_cells.clear()
	
	sim_steps += 1 # This is what causes the dithering, see the above alternation


func set_cell(x: int, y: int, cell: int):
	if x >= 0 and x < matrix_width and y >= 0 and y < matrix_height:
		var idx = y * matrix_width + x
		if matrix[idx] != cell:
			matrix[idx] = cell
			mark_dirty(x, y)

			# Count
			if cell != 0:
				cell_count += 1
			else:
				cell_count -= 1


func mark_dirty(x: int, y: int):
	dirty_cells[Vector2i(x, y)] = true


func get_dirty_cells() -> Dictionary:
	return dirty_cells


func clear_dirty():
	dirty_cells.clear()


func get_cell(x: int, y: int) -> int:
	if x >= 0 and x < matrix_width and y >= 0 and y < matrix_height:
		return matrix[y * matrix_width + x]
	return Registry.elements.EMPTY
