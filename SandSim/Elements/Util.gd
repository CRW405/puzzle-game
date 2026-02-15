extends RefCounted
class_name Util

static var dirty_cells: Dictionary = {}

static func displace(grid: PackedInt32Array, cur_x: int, cur_y: int, new_x: int, new_y: int, this_el: int, other_el: int, width: int):
	grid[new_y * width + new_x] = this_el
	grid[cur_y * width + cur_x] = other_el
	dirty_cells[Vector2i(cur_x, cur_y)] = true
	dirty_cells[Vector2i(new_x, new_y)] = true
