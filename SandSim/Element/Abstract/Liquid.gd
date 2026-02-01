extends Element
class_name Liquid

# Base Liquid abstract class

var dispersion_rate: int = 5

func _init(type: int, col: Color):
	super(type, col)

func can_displace(other_element_type: int) -> bool:
	# Liquids can move into empty spaces and potentially displace gases
	return other_element_type == ElementTypes.EMPTY

func can_be_displaced() -> bool:
	return true

func step(x: int, y: int, grid: Array, grid_width: int, grid_height: int) -> bool:
	if y + 1 >= grid_height:
		return false
	
	# Try moving down first (gravity)
	if grid[y + 1][x] == ElementTypes.EMPTY:
		grid[y + 1][x] = element_type
		grid[y][x] = ElementTypes.EMPTY
		return true
	
	# Try moving down-left or down-right
	var diagonal_dirs = [-1, 1]
	diagonal_dirs.shuffle()
	
	for dir in diagonal_dirs:
		var new_x = x + dir
		if new_x >= 0 and new_x < grid_width:
			if grid[y + 1][new_x] == ElementTypes.EMPTY:
				grid[y + 1][new_x] = element_type
				grid[y][x] = ElementTypes.EMPTY
				return true
	
	# Try spreading horizontally (liquid behavior)
	var horizontal_dirs = [-1, 1]
	horizontal_dirs.shuffle()
	
	for dir in horizontal_dirs:
		var spread_distance = 0
		for dist in range(1, dispersion_rate + 1):
			var new_x = x + (dir * dist)
			if new_x < 0 or new_x >= grid_width:
				break
			if grid[y][new_x] != ElementTypes.EMPTY:
				break
			spread_distance = dist
		
		if spread_distance > 0:
			var target_x = x + (dir * spread_distance)
			grid[y][target_x] = element_type
			grid[y][x] = ElementTypes.EMPTY
			return true
	
	return false
