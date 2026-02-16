extends RefCounted
class_name Water

static func step(matrix: PackedInt32Array, x: int, y: int, matrix_width: int, matrix_height: int):
	## If at bottom, try to spread sideways only
	if y + 1 == matrix_height:
		try_spread(matrix, x, y, matrix_width)
		return
	
	var this_el = Registry.elements.WATER
	var empty = Registry.elements.EMPTY

	var below = matrix[(y + 1) * matrix_width + x]

	## Fall down
	if below == empty:
		Util.displace(matrix, x, y, x, y + 1, this_el, empty, matrix_width)
		return

	## Try diagonal down (like sand but check both)
	var diag = 1 if randi() % 2 == 0 else -1
	var new_x = x + diag

	if new_x >= 0 and new_x < matrix_width:
		var diag_below = matrix[(y + 1) * matrix_width + new_x]
		if diag_below == empty:
			Util.displace(matrix, x, y, new_x, y + 1, this_el, empty, matrix_width)
			return

	## Try other diagonal
	new_x = x - diag
	if new_x >= 0 and new_x < matrix_width:
		var diag_below = matrix[(y + 1) * matrix_width + new_x]
		if diag_below == empty:
			Util.displace(matrix, x, y, new_x, y + 1, this_el, empty, matrix_width)
			return

	## Spread horizontally
	try_spread(matrix, x, y, matrix_width)


static func try_spread(matrix: PackedInt32Array, x: int, y: int, matrix_width: int):
	var this_el = Registry.elements.WATER
	var empty = Registry.elements.EMPTY
	
	# Try spreading multiple cells in one step for faster flow
	var spread_distance = randi_range(1, 5)
	var dir = 1 if randi() % 2 == 0 else -1
	
	# Find furthest empty cell in chosen direction
	var target_x = x
	for i in range(1, spread_distance + 1):
		var check_x = x + (dir * i)
		if check_x < 0 or check_x >= matrix_width:
			break
		if matrix[y * matrix_width + check_x] != empty:
			break
		target_x = check_x
	
	if target_x != x:
		Util.displace(matrix, x, y, target_x, y, this_el, empty, matrix_width)
		return

	# Try other direction
	target_x = x
	for i in range(1, spread_distance + 1):
		var check_x = x - (dir * i)
		if check_x < 0 or check_x >= matrix_width:
			break
		if matrix[y * matrix_width + check_x] != empty:
			break
		target_x = check_x
	
	if target_x != x:
		Util.displace(matrix, x, y, target_x, y, this_el, empty, matrix_width)
