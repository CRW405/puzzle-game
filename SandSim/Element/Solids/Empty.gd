extends Element
class_name Empty

# Empty / Air

func _init():
	super(ElementTypes.EMPTY, Color.BLACK)

func step(x: int, y: int, grid: Array, grid_width: int, grid_height: int) -> bool:
	# Empty doesn't move
	return false
