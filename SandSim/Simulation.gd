extends Node
class_name Simulation

var grid: Array = []
var grid_width: int
var grid_height: int
var simulation_steps: int = 0

func initialize(width: int, height: int):
	grid_width = width
	grid_height = height
	grid.resize(grid_height)
	for y in range(grid_height):
		grid[y] = []
		grid[y].resize(grid_width)
		for x in range(grid_width):
			grid[y][x] = ElementTypes.EMPTY

# Updates the simulation by one frame. Processes elements bottom-to-top using an alternating
# checkerboard scan pattern to prevent update order bias and directional artifacts.
# The starting row and horizontal scan direction alternate each step for fair particle physics.
func step():
	simulation_steps += 1
	var start_y = grid_height - 2 if simulation_steps % 2 == 0 else grid_height - 1
	
	for y in range(start_y, -1, -1):
		var start_x = 0 if (y + simulation_steps) % 2 == 0 else grid_width - 1
		var end_x = grid_width if (y + simulation_steps) % 2 == 0 else -1
		var step_x = 1 if (y + simulation_steps) % 2 == 0 else -1
		
		for x in range(start_x, end_x, step_x):
			var element_type = grid[y][x]
			if element_type == ElementTypes.SAND or element_type == ElementTypes.WATER:
				update_element(x, y)

func update_element(x: int, y: int):
	var element = ElementTypes.create(grid[y][x])
	element.step(x, y, grid, grid_width, grid_height)

func set_cell(x: int, y: int, cell_type):
	if x >= 0 and x < grid_width and y >= 0 and y < grid_height:
		grid[y][x] = cell_type

func get_cell(x: int, y: int):
	if x >= 0 and x < grid_width and y >= 0 and y < grid_height:
		return grid[y][x]
	return null

func count_cells() -> int:
	var count = 0
	for y in range(grid_height):
		for x in range(grid_width):
			if grid[y][x] != ElementTypes.EMPTY:
				count += 1
	return count
