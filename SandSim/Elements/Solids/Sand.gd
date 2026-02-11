extends RefCounted
class_name Sand

static func step(matrix: Array, x: int, y: int, matrix_width: int, matrix_height: int):
	## If at bottom, do nothing
	if y + 1 == matrix_height:
		return   
	
	var this_el = Registry.elements.SAND
	var empty = Registry.elements.EMPTY

	var here = matrix[y][x]
	var below = matrix[y + 1][x]

	## moving down
	if below == empty:
		Util.displace(matrix, x, y, x, y + 1, this_el, empty)
		return

	## Sink
	pass

	## Pile (move diagonally)
	var diag = 1 if randi() % 2 == 0 else -1 # random int either 1 or -1
	var new_x = x + diag # either left or right of current position

	## Attempt first choice as long as its inside the grid
	if new_x >= 0 and new_x < matrix_width:
		var new_pos = matrix[y + 1][new_x]

		if new_pos == empty:
			Util.displace(matrix, x, y, new_x, y + 1, this_el, empty)
			return

		## Sink
	
	## repeat for other direction
	new_x = x - diag
	if new_x >= 0 and new_x < matrix_width:
		var new_pos = matrix[y + 1][new_x]

		if new_pos == empty:
			Util.displace(matrix, x, y, new_x, y + 1, this_el, empty)
