# ElementSand.gd
extends Element
class_name ElementSand

func update(i: int, pos: PackedVector2Array, vel: PackedVector2Array, is_stopped: PackedByteArray, screen_height: float, floor_heights: PackedFloat32Array, particle_size: int) -> void:
	# 1. Physics (Standard Gravity)
	vel[i].y += 980.0 * 0.016 # (Using fixed delta approx for simplicity in resource)
	
	# 2. Collision Logic (The "Avalanche" Code)
	var col = int(pos[i].x / particle_size)
	var max_col = floor_heights.size() - 1
	
	if col >= 0 and col <= max_col:
		var pile_h = floor_heights[col]
		var current_floor = screen_height - pile_h
		
		if pos[i].y >= current_floor:
			# Check Neighbors
			var left = floor_heights[col - 1] if col > 0 else 99999.0
			var right = floor_heights[col + 1] if col < max_col else 99999.0
			
			if col > 0 and left < pile_h - particle_size:
				pos[i].x -= particle_size # Slide Left
				pos[i].y = current_floor - 1
			elif col < max_col and right < pile_h - particle_size:
				pos[i].x += particle_size # Slide Right
				pos[i].y = current_floor - 1
			else:
				# Stop
				pos[i].y = current_floor - particle_size
				vel[i] = Vector2.ZERO
				is_stopped[i] = 1
				floor_heights[col] += particle_size
