## Define element id, name, color, and assign behaviours
extends RefCounted
class_name Registry

enum elements {
	EMPTY,
	WALL,
	SAND,
	WATER
}

# groups to simlify some lookups
const UNMOVING: Array[int] = [elements.EMPTY, elements.WALL]
const MOVING: Array[int] = [elements.SAND, elements.WATER]


static func get_color(type: int) -> Color:
	match type:
		elements.EMPTY:
			return Color.BLACK
		elements.WALL:
			return Color.GRAY
		elements.SAND:
			return Color.YELLOW
		elements.WATER:
			return Color.BLUE
		_: # Defualt / Fallback
			return Color.BLACK


static func get_name(type: int) -> String:
	match type:
		elements.EMPTY:
			return "Empty"
		elements.WALL:
			return "Wall"
		elements.SAND:
			return "Sand"
		elements.WATER:
			return "Water"
		_: # Defualt / Fallback
			return "Unknown"


##  matches <element>behaviour to <element>
static func get_behaviour(type: int, grid: Array, x: int, y: int, grid_width: int, grid_height: int):
	match type:
		elements.SAND:
			return Sand.step(grid, x, y, grid_width, grid_height)
		_:
			return
