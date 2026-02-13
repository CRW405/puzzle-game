extends RefCounted
class_name Util

static var dirty_cells: Dictionary = {}

static func displace(grid: Array, cur_x: int, cur_y: int, new_x: int, new_y: int, this_el: int, other_el: int):
	grid[new_y][new_x] = this_el
	grid[cur_y][cur_x] = other_el
	dirty_cells[Vector2i(cur_x, cur_y)] = true
	dirty_cells[Vector2i(new_x, new_y)] = true
