## WaterBehavior - Physics for Water Particles
##
## Water is a liquid that:
## - Falls straight down under gravity
## - Slides diagonally when blocked
## - Spreads horizontally to fill containers
## - Rises when heavy particles sink through it
##
## The horizontal dispersion creates realistic liquid flow.
## Water searches up to DISPERSION_RATE cells away to find spreading opportunities.

extends RefCounted
class_name WaterBehavior

# How far water can spread horizontally in one step
# Higher values = faster spreading, more dramatic water flow
# 5 creates a good balance between realism and performance
const DISPERSION_RATE = 5

## Performs one physics step for a water particle
## Returns the new position if it moved, or (-1, -1) if it stayed in place
static func step(x: int, y: int, grid: Array, grid_width: int, grid_height: int) -> Vector2i:
	# Can't move if we're at the bottom of the grid
	if y + 1 >= grid_height:
		return Vector2i(-1, -1)
	
	# Priority 1: Try moving straight down (gravity)
	# Water falls just like sand when there's space below
	if grid[y + 1][x] == ElementTypes.EMPTY:
		grid[y + 1][x] = ElementTypes.WATER
		grid[y][x] = ElementTypes.EMPTY
		return Vector2i(x, y + 1)
	
	# Priority 2: Try moving diagonally down
	# Randomly choose left or right first to prevent bias
	var diag_dir = 1 if randi() % 2 == 0 else -1
	var new_x = x + diag_dir
	
	# Try first diagonal direction
	if new_x >= 0 and new_x < grid_width:
		if grid[y + 1][new_x] == ElementTypes.EMPTY:
			grid[y + 1][new_x] = ElementTypes.WATER
			grid[y][x] = ElementTypes.EMPTY
			return Vector2i(new_x, y + 1)
	
	# Try other diagonal direction
	new_x = x - diag_dir
	if new_x >= 0 and new_x < grid_width:
		if grid[y + 1][new_x] == ElementTypes.EMPTY:
			grid[y + 1][new_x] = ElementTypes.WATER
			grid[y][x] = ElementTypes.EMPTY
			return Vector2i(new_x, y + 1)
	
	# Priority 3: Spread horizontally (key liquid behavior)
	# This is what makes water flow sideways and fill containers
	var horiz_dir = 1 if randi() % 2 == 0 else -1
	var spread_distance = 0
	
	# Search for empty space horizontally
	# Move to the furthest empty cell within DISPERSION_RATE
	for dist in range(1, DISPERSION_RATE + 1):
		new_x = x + (horiz_dir * dist)
		# Stop if we hit a boundary
		if new_x < 0 or new_x >= grid_width:
			break
		# Stop if we hit a solid element
		if grid[y][new_x] != ElementTypes.EMPTY:
			break
		# This distance is valid for spreading
		spread_distance = dist
	
	# If we found empty space, jump to the furthest empty cell
	if spread_distance > 0:
		var target_x = x + (horiz_dir * spread_distance)
		grid[y][target_x] = ElementTypes.WATER
		grid[y][x] = ElementTypes.EMPTY
		return Vector2i(target_x, y)
	
	# Priority 4: Try spreading in the other horizontal direction
	horiz_dir = -horiz_dir
	spread_distance = 0
	
	# Search for empty space in the opposite direction
	for dist in range(1, DISPERSION_RATE + 1):
		new_x = x + (horiz_dir * dist)
		if new_x < 0 or new_x >= grid_width:
			break
		if grid[y][new_x] != ElementTypes.EMPTY:
			break
		spread_distance = dist
	
	# Move to furthest empty cell in this direction
	if spread_distance > 0:
		var target_x = x + (horiz_dir * spread_distance)
		grid[y][target_x] = ElementTypes.WATER
		grid[y][x] = ElementTypes.EMPTY
		return Vector2i(target_x, y)
	
	# Can't move anywhere - water is settled
	return Vector2i(-1, -1)
