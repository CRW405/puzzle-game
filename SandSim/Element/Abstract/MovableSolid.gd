extends Solid
class_name MovableSolid

# base abstract movable solid class for things like sand or gravel

func _init(type: int, col: Color):
	super(type, col)

# Movable solids can be displaced by other movable solids or liquids
func can_be_displaced() -> bool:
	return true

func step(x: int, y: int, grid: Array, grid_width: int, grid_height: int) -> bool:
	if y + 1 >= grid_height:
		return false
	
	var below = grid[y + 1][x]
	
	# Try moving down into empty space
	if below == ElementTypes.EMPTY:
		grid[y + 1][x] = element_type
		grid[y][x] = ElementTypes.EMPTY
		return true
	
	# Movable solids sink through liquids (swap positions)
	if below == ElementTypes.WATER:
		grid[y + 1][x] = element_type
		grid[y][x] = below
		return true
	
	# Try moving down-left or down-right
	var directions = [-1, 1]
	directions.shuffle()
	
	for dir in directions:
		var new_x = x + dir
		if new_x >= 0 and new_x < grid_width:
			var diagonal = grid[y + 1][new_x]
			
			# Move into empty space diagonally
			if diagonal == ElementTypes.EMPTY:
				grid[y + 1][new_x] = element_type
				grid[y][x] = ElementTypes.EMPTY
				return true
			
			# Sink through liquid diagonally
			if diagonal == ElementTypes.WATER:
				grid[y + 1][new_x] = element_type
				grid[y][x] = diagonal
				return true
	
	return false

