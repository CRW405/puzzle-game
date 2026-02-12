# ElementStone.gd
extends Element
class_name ElementStone

func update(i: int, pos: PackedVector2Array, vel: PackedVector2Array, is_stopped: PackedByteArray, screen_height: float, floor_heights: PackedFloat32Array, particle_size: int) -> void:
	# Stone snaps to grid instantly and stops
	vel[i] = Vector2.ZERO
	is_stopped[i] = 1
	
	# Update heightmap immediately so sand hits it
	var col = int(pos[i].x / particle_size)
	if col >= 0 and col < floor_heights.size():
		floor_heights[col] += particle_size
