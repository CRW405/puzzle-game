extends RefCounted
class_name Sand

static func step(grid: Array, x: int, y: int, grid_width: int, grid_height: int):
	## If at bottom, do nothing
	if y++ == grid_height:
		return   
	
	var this_el = ElementRegistry.SAND
	var empty = ElementRegistry.EMPTY

	var here = grid[y][x]
	var below = grid[y++][x]

	## moving down
	if below = empty:
		Util.displace(grid, x, y, x, y++, this_el, empty)

	## Sink
	pass

	## Pile (move diagonally)
	var diag = 1 if randi() % 2 == 0 else -1 # random int either 1 or -1
	var new_x = x + diag # either left or right of current position

	## Attempt first choice as long as its inside the grid
	if new_x < grid_width:
		var new_pos = grid[y++][new_x]

		if new_pos == empty:
			Util.displace(grid, x, y, new_x, y++, this_el, empty)

		## Sink
	
	## repeat for other direction
	new_x = x - diag
	if new_x < grid_width:
		var new_pos = grid[y++][new_x]

		if new_pos == empty:
			Util.displace(grid, x, y, new_x, y++, this_el, empty)

	
