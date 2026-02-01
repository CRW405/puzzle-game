extends RefCounted
class_name ElementTypes

# This class is so that we can associate an element with an int so 
# that we can seperate the grid from individual element logic
# Also defines how the elements look in the renderer

enum {
EMPTY,
SAND,
WALL,
WATER
}

static func create(element_type: int) -> Element:
	match element_type:
		EMPTY:
			return Empty.new()
		SAND:
			return Sand.new()
		WALL:
			return Wall.new()
		WATER:
			return Water.new()
		_:
			return Empty.new()

static func get_color(element_type: int) -> Color:
	match element_type:
		EMPTY:
			return Color.BLACK
		SAND:
			return Color.YELLOW
		WALL:
			return Color.GRAY
		WATER:
			return Color.DODGER_BLUE
		_:
			return Color.BLACK

static func get_element_name(element_type: int) -> String:
	match element_type:
		EMPTY:
			return "Empty"
		SAND:
			return "Sand"
		WALL:
			return "Wall"
		WATER:
			return "Water"
		_:
			return "Unknown"
