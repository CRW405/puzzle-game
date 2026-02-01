extends Solid
class_name ImmovableSolid

# Base abstract Immovable Solid class for things like Wall and Wood

func _init(type: int, col: Color):
	super(type, col)

func step(x: int, y: int, grid: Array, grid_width: int, grid_height: int) -> bool:
	# Immovable solids never move
	return false

func can_displace(other_element_type: int) -> bool:
	# Immovable solids can't be displaced
	return false

func can_be_displaced() -> bool:
	return false
