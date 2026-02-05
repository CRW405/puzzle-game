## ElementBehaviors - Central Behavior Dispatcher
##
## This class routes element physics to the appropriate behavior file.
## It acts as a central hub that keeps the behavior code organized.
##
## Why use a dispatcher?
## - Each element's behavior is in its own file (easy to find and edit)
## - Adding new elements just means adding a new case here
## - All behavior functions use the same static interface
##
## To add a new element:
## 1. Add the constant to ElementTypes.gd
## 2. Create a new behavior file (e.g., LavaBehavior.gd)
## 3. Add a case here to route to that behavior
## 4. Update the renderer atlas and simulation active check

extends RefCounted
class_name ElementBehaviors

## Dispatches physics step to the appropriate element behavior
## This is called for every active element every simulation step
##
## Parameters:
##   element_type: The type of element (SAND, WATER, etc.)
##   x, y: Current position in the grid
##   grid: Reference to the full grid array
##   grid_width, grid_height: Grid dimensions for bounds checking
##
## Returns:
##   Vector2i of new position if element moved, or Vector2i(-1, -1) if it didn't move
static func step(element_type: int, x: int, y: int, grid: Array, grid_width: int, grid_height: int) -> Vector2i:
	match element_type:
		ElementTypes.SAND:
			return SandBehavior.step(x, y, grid, grid_width, grid_height)
		ElementTypes.WATER:
			return WaterBehavior.step(x, y, grid, grid_width, grid_height)
		_:  # Unknown element types don't move
			return Vector2i(-1, -1)
