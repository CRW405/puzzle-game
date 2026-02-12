# Element.gd
extends Resource
class_name Element

@export var color: Color = Color.WHITE

# Virtual function: Overridden by specific elements
# We pass the arrays directly for maximum performance
func update(i: int, pos: PackedVector2Array, vel: PackedVector2Array, is_stopped: PackedByteArray, screen_height: float, floor_heights: PackedFloat32Array, particle_size: int) -> void:
	pass
