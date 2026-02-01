extends Element
class_name Gas

# Base abstract gas class

func _init(type: int, col: Color):
	super(type, col)

func can_displace(other_element_type: int) -> bool:
	# Gases can only move into empty spaces
	return other_element_type == ElementTypes.EMPTY
