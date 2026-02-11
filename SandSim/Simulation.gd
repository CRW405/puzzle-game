## main physics driver, 
## stores and performs actions on the matrix

extends Node
class_name Simulation

## Setup
var matrix: Array = []
var matrix_width: int
var matrix_height: int
var sim_steps: int

#...


func _init(width: int, height: int):
	matrix_width = width
	matrix_height = height
	matrix.resize(matrix_height)
	for y in range(matrix_height):
		matrix[y] = []
		matrix[y].resize(matrix_width)
		for x in range(matrix_width):
			matrix[y][x] = Registry.elements.EMPTY


## Move the sim forward, physics update
func stepAll():
	# alternates start for more natual looking physics 
	var start_y = matrix_height - 2 if sim_steps % 2 == 0 else matrix_height -1

	# process bottom to top so we dont get weird gravity
	for y in range(start_y, -1, -1):
		## more alternation, in conjuction with the alternating y, 
		## we get a checkerboard pattern which helps to make the physics 
		## seem a little more natural and less 'stilted'
		var start_x = 0 if (y + sim_steps) % 2 == 0 else matrix_width -1
		var end_x = matrix_width if (y + sim_steps) % 2 == 0 else -1
		var step_x = 1 if (y + sim_steps) % 2 == 0 else -1

		for x in range(start_x, end_x, step_x):
			var cell = matrix[y][x]

			if cell in Registry.UNMOVING:
				continue
			
			if cell in Registry.MOVING:
				Registry.get_behaviour(cell, matrix, x, y, matrix_width, matrix_height)


func set_cell(x: int, y: int, cell: int):
	if x >= 0 and x < matrix_width and y >= 0 and y < matrix_height:
		matrix[y][x] = cell


func get_cell(x: int, y: int) -> int:
	if x >= 0 and x < matrix_width and y >= 0 and y < matrix_height:
		return matrix[y][x]
	return Registry.elements.EMPTY
