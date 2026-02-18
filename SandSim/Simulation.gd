## main physics driver, 
## stores and performs actions on the matrix

class_name Simulation
extends Node2D

## Setup
var matrix: PackedInt32Array = PackedInt32Array()
var matrix_width: int
var matrix_height: int
var sim_steps: int
var cell_count: int = 0
var dirty_cells: PackedByteArray = PackedByteArray()  # Bitfield for dirty rendering

## Chunk-based sleep system
const CHUNK_SIZE: int = 16 # 16 seems best from whar I've tinkered with
const SLEEP_THRESHOLD: int = 2  # Frames of inactivity before sleeping
var chunks_wide: int
var chunks_high: int
var chunk_activity: PackedInt32Array  # Countdown timer per chunk (0 = sleeping)


func initialize(width: int, height: int):
	matrix_width = width
	matrix_height = height
	matrix.resize(matrix_width * matrix_height)
	matrix.fill(Registry.elements.EMPTY)
	
	# Initialize chunk system
	chunks_wide = ceili(float(matrix_width) / CHUNK_SIZE)
	chunks_high = ceili(float(matrix_height) / CHUNK_SIZE)
	chunk_activity.resize(chunks_wide * chunks_high)
	chunk_activity.fill(0)
	
	# Initialize dirty cell bitfield
	dirty_cells.resize(matrix_width * matrix_height)
	dirty_cells.fill(0)


## Move the sim forward, physics update
func stepAll():
	var unmoving = Registry.UNMOVING
	var moving = Registry.MOVING
	
	# Decrement all active chunk timers
	for i in range(chunk_activity.size()):
		if chunk_activity[i] > 0:
			chunk_activity[i] -= 1
	
	# alternates start for more natural looking physics 
	var start_y = matrix_height - 2 if sim_steps % 2 == 0 else matrix_height - 1

	# process bottom to top so we dont get weird gravity
	for y in range(start_y, -1, -1):
		var chunk_y = y / CHUNK_SIZE
		
		## more alternation, in conjuction with the alternating y, 
		## we get a checkerboard pattern which helps to make the physics 
		## seem a little more natural
		var left_to_right = (y + sim_steps) % 2 == 0
		var start_x = 0 if left_to_right else matrix_width - 1
		var end_x = matrix_width if left_to_right else -1
		var step_x = 1 if left_to_right else -1

		for x in range(start_x, end_x, step_x):
			# Skip sleeping chunks
			var chunk_x = x / CHUNK_SIZE
			var chunk_idx = chunk_y * chunks_wide + chunk_x
			if chunk_activity[chunk_idx] == 0:
				continue
			
			var cell = matrix[y * matrix_width + x]
	
			# unmoving elements do not need to be processed directly
			if cell in unmoving:
				continue
			
			if cell in moving:
				Registry.get_behaviour(cell, matrix, x, y, matrix_width, matrix_height)
	
	# Process dirty cells and wake chunks
	for pos in Util.dirty_cells:
		wake_chunk_at(pos.x, pos.y)
		dirty_cells[pos.y * matrix_width + pos.x] = 1
	Util.dirty_cells.clear()
	
	sim_steps += 1 # This is what causes the dithering, see the above alternation


func set_cell(x: int, y: int, cell: int):
	if x >= 0 and x < matrix_width and y >= 0 and y < matrix_height:
		var idx = y * matrix_width + x
		if matrix[idx] != cell:
			matrix[idx] = cell
			mark_dirty(x, y)
			wake_chunk_at(x, y)

			# Count
			if cell != 0:
				cell_count += 1
			else:
				cell_count -= 1


func mark_dirty(x: int, y: int):
	dirty_cells[y * matrix_width + x] = 1


func get_dirty_cells() -> PackedByteArray:
	return dirty_cells


func clear_dirty():
	dirty_cells.fill(0)


func get_cell(x: int, y: int) -> int:
	if x >= 0 and x < matrix_width and y >= 0 and y < matrix_height:
		return matrix[y * matrix_width + x]
	return Registry.elements.EMPTY


## Chunk management
func wake_chunk_at(x: int, y: int):
	var chunk_x = x / CHUNK_SIZE
	var chunk_y = y / CHUNK_SIZE
	var chunk_idx = chunk_y * chunks_wide + chunk_x
	chunk_activity[chunk_idx] = SLEEP_THRESHOLD
	
	# Wake adjacent chunks if cell is on a boundary
	var local_x = x % CHUNK_SIZE
	var local_y = y % CHUNK_SIZE
	
	if local_x == 0 and chunk_x > 0:
		chunk_activity[chunk_idx - 1] = SLEEP_THRESHOLD
	if local_x == CHUNK_SIZE - 1 and chunk_x < chunks_wide - 1:
		chunk_activity[chunk_idx + 1] = SLEEP_THRESHOLD
	if local_y == 0 and chunk_y > 0:
		chunk_activity[chunk_idx - chunks_wide] = SLEEP_THRESHOLD
	if local_y == CHUNK_SIZE - 1 and chunk_y < chunks_high - 1:
		chunk_activity[chunk_idx + chunks_wide] = SLEEP_THRESHOLD
