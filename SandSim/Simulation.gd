## main physics driver, 
## stores and performs actions on the matrix

extends Node
class_name Simulation

## Setup
var matrix: Array = []
var grid_width: int
var grid_height: int

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
	pass


func set():
	pass


func get():
	pass


