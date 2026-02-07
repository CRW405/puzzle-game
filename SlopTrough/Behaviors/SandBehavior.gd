## SandBehavior - Physics for Sand Particles
##
## Sand is a heavy powder that:
## - Falls straight down when there's empty space below
## - Slides diagonally when it hits something
## - Sinks through liquids by swapping positions
## - Settles into stable piles
##
## The behavior is deterministic with randomness for left/right choices.
## This creates natural-looking sand piles without complex cellular automata.

extends RefCounted
class_name SandBehavior

## Performs one physics step for a sand particle
## Returns the new position if it moved, or (-1, -1) if it stayed in place
static func step(x: int, y: int, grid: Array, grid_width: int, grid_height: int) -> Vector2i:
	# Can't move if we're at the bottom of the grid
	if y + 1 >= grid_height:
		return Vector2i(-1, -1)
	
	var below = grid[y + 1][x]
	
	# Priority 1: Try moving straight down into empty space
	if below == ElementTypes.EMPTY:
		grid[y + 1][x] = ElementTypes.SAND
		grid[y][x] = ElementTypes.EMPTY
		return Vector2i(x, y + 1)
	
	# Priority 2: Sink through liquids by swapping positions
	# This creates realistic water displacement as sand sinks
	if below == ElementTypes.WATER:
		grid[y + 1][x] = ElementTypes.SAND  # Sand moves down
		grid[y][x] = below                   # Water moves up
		return Vector2i(x, y + 1)
	
	# Priority 3: Try moving diagonally (creates piles and slides)
	# Randomly choose left or right first to prevent bias
	var dir = 1 if randi() % 2 == 0 else -1
	var new_x = x + dir
	
	# Try first diagonal direction
	if new_x >= 0 and new_x < grid_width:
		var diagonal = grid[y + 1][new_x]
		
		# Move into empty diagonal space
		if diagonal == ElementTypes.EMPTY:
			grid[y + 1][new_x] = ElementTypes.SAND
			grid[y][x] = ElementTypes.EMPTY
			return Vector2i(new_x, y + 1)
		
		# Sink diagonally through liquid
		if diagonal == ElementTypes.WATER:
			grid[y + 1][new_x] = ElementTypes.SAND
			grid[y][x] = diagonal
			return Vector2i(new_x, y + 1)
	
	# Priority 4: Try the other diagonal direction
	new_x = x - dir
	if new_x >= 0 and new_x < grid_width:
		var diagonal = grid[y + 1][new_x]
		
		# Move into empty diagonal space
		if diagonal == ElementTypes.EMPTY:
			grid[y + 1][new_x] = ElementTypes.SAND
			grid[y][x] = ElementTypes.EMPTY
			return Vector2i(new_x, y + 1)
		
		# Sink diagonally through liq euid
		if diagonal == ElementTypes.WATER:
			grid[y + 1][new_x] = ElementTypes.SAND
			grid[y][x] = diagonal
			return Vector2i(new_x, y + 1)
	
	# Can't move anywhere - particle is settled
	return Vector2i(-1, -1)
