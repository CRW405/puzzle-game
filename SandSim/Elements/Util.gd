extends RefCounted
class_name Util

static func displace(grid: Array, cur_x: int, cur_y: int, new_x: int, new_y: int, this_el: int, other_el: int):
	grid[new_y][new_x] = this_el
	grid[cur_y][cur_x] = other_el
