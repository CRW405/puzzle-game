## main physics driver, 
## stores and performs actions on the matrix

extends Node
class_name Simulation

## Setup
var matrix: Array = []
var grid_width: int
var grid_height: int
var sim_steps: int

#...


func init(width: int, height: int):
	grid_width = width
	grid_height = height
	grid.resize(grid_height)
	for y in range(grid_height):
		grid[y] = []
		grid[y].resize(grid_width)
		for x in range(grid_width):
			grid[y][x] = Registry.EMPTY


## Move the sim forward, physics update
func stepAll():

	# alternates start for more natual looking physics 
	var start_y = grid_height - 2 if sim_steps % 2 == 0 else grid_height -1

	# process bottom to top so we dont get weird gravity
	for y in range(start_y, -1, -1):
		## more alternation, in conjuction with the alternating y, 
		## we get a checkerboard pattern which helps to make the physics 
		## seem a little more natural and less 'stilted'
		var start_x = 0 if (y + sim_steps) % 2 == 0 else grid_height -1
		var end_x = grid_width if (y + sim_steps) % 2 == 0 else -1
		var step_x = 1 if (y + sim_steps) % 2 == 0 else -1

		for x in range(start_x, end_x, step_x):
			var cell = grid[y][x]

			if cell in Registry.UNMOVING:
				continue
			
			if cell in Registry.MOVING:
				Registry.step(cell, x, y, grid, grid_width, grid_height)


func set(x: int, y: int, cell: int):
	if x >= 0 and x < grid_width and y >= 0 and y < grid_height:
		grid[y][x] = cell


func get():
	pass


