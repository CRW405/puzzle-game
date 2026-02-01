extends RefCounted
class_name Element

# Base abstract element class

var element_type: int
var color: Color

func _init(type: int, col: Color):
	element_type = type
	color = col

# Override in subclasses to define movement behavior
func step(x: int, y: int, grid: Array, grid_width: int, grid_height: int) -> bool:
	return false

# Check if this element can move into another element
func can_displace(other_element_type: int) -> bool:
	return false
