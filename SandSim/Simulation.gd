## Simulation - The Physics Engine
##
## This class manages the core particle simulation logic.
## It stores the grid state and runs physics updates each frame.
##
## Key Optimizations:
## - Checkerboard scanning prevents directional bias (particles don't favor one side)
## - Dirty cell tracking (only changed cells are re-rendered)
## - Cached active cell count (O(1) instead of O(n²) grid scan)
##
## The grid is a 2D array where each cell contains an element type integer.
## This simple representation is extremely fast - no object overhead.

extends Node
class_name Simulation

# The main grid - 2D array of element type integers
# grid[y][x] = ElementTypes constant (EMPTY, SAND, WALL, WATER)
var grid: Array = []

# Grid dimensions
var grid_width: int
var grid_height: int

# Counts simulation steps to alternate scanning pattern
var simulation_steps: int = 0

# Cached count of non-empty cells for performance
var active_cell_count: int = 0

# Tracks which cells changed this frame for efficient rendering
# Key = Vector2i(x, y), Value = true
var dirty_cells: Dictionary = {}

## Initializes the simulation grid
## Creates a 2D array filled with EMPTY cells
## This is called once at startup
func initialize(width: int, height: int):
	grid_width = width
	grid_height = height
	
	# Create the 2D grid structure
	# First dimension is Y (rows), second is X (columns)
	grid.resize(grid_height)
	for y in range(grid_height):
		grid[y] = []
		grid[y].resize(grid_width)
		# Fill each cell with EMPTY (air/void)
		for x in range(grid_width):
			grid[y][x] = ElementTypes.EMPTY

## Updates the simulation by one physics step
## This clears dirty cells and then runs one physics update
## Use this if calling step() once per frame
func step():
	dirty_cells.clear()  # Reset dirty tracking each frame
	step_without_clear()

## Runs one physics update WITHOUT clearing dirty cells
## This allows multiple simulation steps per frame while tracking all changes
## The checkerboard pattern prevents particles from always favoring one direction
func step_without_clear():
	simulation_steps += 1
	
	# Alternate starting row each step to prevent bias
	# Even steps start at second-to-last row, odd steps at last row
	var start_y = grid_height - 2 if simulation_steps % 2 == 0 else grid_height - 1
	
	# Process grid bottom-to-top (gravity effect)
	for y in range(start_y, -1, -1):
		# Alternate horizontal scan direction based on row + step count
		# This creates a checkerboard pattern that changes each frame
		var start_x = 0 if (y + simulation_steps) % 2 == 0 else grid_width - 1
		var end_x = grid_width if (y + simulation_steps) % 2 == 0 else -1
		var step_x = 1 if (y + simulation_steps) % 2 == 0 else -1
		
		# Scan row left-to-right or right-to-left
		for x in range(start_x, end_x, step_x):
			var element_type = grid[y][x]
			
			# Skip empty cells and static walls - they don't move
			if element_type == ElementTypes.EMPTY or element_type == ElementTypes.WALL:
				continue
			
			# Process movable elements (sand and water)
			if element_type == ElementTypes.SAND or element_type == ElementTypes.WATER:
				# Call the element's behavior function to get new position
				var new_pos = ElementBehaviors.step(element_type, x, y, grid, grid_width, grid_height)
				
				# If element moved (new_pos != -1, -1)
				if new_pos.x != -1:
					# Mark old position as dirty (now empty or different)
					mark_dirty(x, y)
					# Mark new position as dirty (now has element)
					mark_dirty(new_pos.x, new_pos.y)

## Marks a cell as dirty (changed) so it will be re-rendered
## Uses a Dictionary for fast O(1) lookup and deduplication
func mark_dirty(x: int, y: int):
	var key = Vector2i(x, y)
	dirty_cells[key] = true

## Sets a cell to a specific element type
## This is called when the user places or erases elements
## Automatically updates the active cell counter and marks the cell dirty
func set_cell(x: int, y: int, cell_type):
	# Bounds check
	if x >= 0 and x < grid_width and y >= 0 and y < grid_height:
		var old_type = grid[y][x]
		grid[y][x] = cell_type
		mark_dirty(x, y)
		
		# Update cached cell count for O(1) counting
		# Increment when placing a new element
		if old_type == ElementTypes.EMPTY and cell_type != ElementTypes.EMPTY:
			active_cell_count += 1
		# Decrement when removing an element
		elif old_type != ElementTypes.EMPTY and cell_type == ElementTypes.EMPTY:
			active_cell_count -= 1

## Gets the element type at a specific grid position
## Returns null if out of bounds
func get_cell(x: int, y: int):
	if x >= 0 and x < grid_width and y >= 0 and y < grid_height:
		return grid[y][x]
	return null

## Returns the number of non-empty cells
## This uses a cached counter, so it's O(1) instead of scanning the entire grid
func count_cells() -> int:
	return active_cell_count

## Returns the dictionary of dirty cells for this frame
## Renderer uses this to only redraw changed cells
func get_dirty_cells() -> Dictionary:
	return dirty_cells
