## Define element id, name, color, and assign behaviours
extends RefCounted
class_name ElementRegistry

enum elements {
	EMPTY,
	WALL,
	SAND,
	WATER
}

# groups to simlify some lookups
const UNMOVING: Array[int] = [EMPTY, WALL]
const MOVING: Array[int] = [SAND, WATER]


static func get_color(type: int) -> Color:
	match type:
		EMPTY:
			return Color.BLACK
		WALL:
			return Color.GREY
		SAND:
			return Color.YELLOW
		WATER:
			return Color.BLUE
		_: # Defualt / Fallback
			return Color.BLACK


static func get_name(type: int) -> String:
	match type:
		EMPTY:
			return "Empty"
		WALL:
			return "Wall"
		SAND:
			return "Sand"
		WATER:
			return "Water"
		_: # Defualt / Fallback
			return "Unknown"


##  matches <element>behaviour to <element>
static func get_behaviour(type: int, grid: Array, x: int, y: int, grid_width: int, grid_height: int):
	match type:
		SAND:
			return Sand.step(grid, x, y, grid_width, grid_height)
		_:
			return
