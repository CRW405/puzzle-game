extends Element
class_name Solid

# Base Abstract Solid class that movable and immovable solids inherit from

func _init(type: int, col: Color):
	super(type, col)

func can_displace(other_element_type: int) -> bool:
	# Solids can move into empty spaces
	return other_element_type == ElementTypes.EMPTY
