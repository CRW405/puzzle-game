# ElementWater.gd
extends Element
class_name ElementWater

func update(i: int, pos: PackedVector2Array, vel: PackedVector2Array, is_stopped: PackedByteArray, screen_height: float, floor_heights: PackedFloat32Array, particle_size: int) -> void:
	vel[i].y += 980.0 * 0.016
	
	var col = int(pos[i].x / particle_size)
	var max_col = floor_heights.size() - 1

	if col >= 0 and col <= max_col:
		var pile_h = floor_heights[col]
		var current_floor = screen_height - pile_h
		
		if pos[i].y >= current_floor:
			# Water Logic: ALWAYS try to flow side-to-side if on floor
			var left = floor_heights[col - 1] if col > 0 else 99999.0
			var right = floor_heights[col + 1] if col < max_col else 99999.0
			
			# If a hole exists nearby, fall into it
			if col > 0 and left < pile_h:
				pos[i].x -= particle_size
			elif col < max_col and right < pile_h:
				pos[i].x += particle_size
			else:
				# If flat, jitter/flow
				var dir = -1 if randf() < 0.5 else 1
				pos[i].x += dir * particle_size
				
			# Keep on top of floor
			pos[i].y = current_floor - particle_size
			vel[i].y = 0 # Reset vertical velocity
			
			# Water NEVER sets "is_stopped = 1" because it always flows!
