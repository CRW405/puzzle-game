extends Node2D
class_name Player

## Movement settings
@export var move_speed: float = 60.0
@export var gravity: float = 200.0
@export var jump_velocity: float = -120.0
@export var max_step_height: int = 2  # Max cells player can step up

## Swim Setup
@export var swim_speed: float = 40.0
@export var swim_vertical_speed: float = 40.0
@export var swim_drag: float = 6.0
@export var swim_gravity_scale: float = 0.3

## References
var sim: Simulation
var tile_size: int

## State
var velocity: Vector2 = Vector2.ZERO
var player_width: int = 27  # pixels
var player_height: int = 27  # pixels

## Visual
var sprite: ColorRect


func initialize(simulation: Simulation, t_size: int):
	sim = simulation
	tile_size = t_size
	
	# Create simple colored rectangle as placeholder sprite
	sprite = ColorRect.new()
	sprite.size = Vector2(player_width, player_height)
	sprite.color = Color.GREEN
	sprite.position = Vector2(-player_width / 2, -player_height)  # Anchor at feet
	add_child(sprite)
	
	# Start player in upper middle of world
	position = Vector2(sim.matrix_width * tile_size / 2, 20)


func _process(delta):
	if sim == null:
		return
	handle_input(delta)
	apply_gravity(delta)
	move(delta)


func handle_input(delta):
	var input_dir = 0
	if Input.is_action_pressed("ui_left") || Input.is_key_pressed(KEY_A):
		input_dir -= 1
	if Input.is_action_pressed("ui_right") || Input.is_key_pressed(KEY_D):
		input_dir += 1
	
	var in_liquid = is_in_liquid(position.x, position.y)
	if in_liquid:
		velocity.x = input_dir * swim_speed
	else:
		velocity.x = input_dir * move_speed
	
	# Vertical swim control in liquids
	if in_liquid:
		var vdir = 0
		if Input.is_action_pressed("ui_up") || Input.is_key_pressed(KEY_W):
			vdir -= 1
		if Input.is_action_pressed("ui_down") || Input.is_key_pressed(KEY_S):
			vdir += 1
		if vdir != 0:
			velocity.y = vdir * swim_vertical_speed
	else:
		# Jump if on ground
		if (Input.is_action_just_pressed("ui_up") || Input.is_key_pressed(KEY_W)) and is_on_ground():
			velocity.y = jump_velocity
	
	# Respawn at top (R key)
	if Input.is_key_pressed(KEY_R):
		respawn()


func respawn():
	position = Vector2(sim.matrix_width * tile_size / 2, 20)
	velocity = Vector2.ZERO


func apply_gravity(delta):
	var in_liquid = is_in_liquid(position.x, position.y)
	if in_liquid:
		# Reduced gravity and drag in liquid
		velocity.y += gravity * delta * swim_gravity_scale
		# Apply drag to slow movement
		velocity = velocity.lerp(Vector2.ZERO, clamp(swim_drag * delta, 0, 1))
	else:
		if not is_on_ground():
			velocity.y += gravity * delta
		elif velocity.y > 0:
			velocity.y = 0


func move(delta):
	var new_pos = position + velocity * delta
	
	# Horizontal movement with incline stepping
	if velocity.x != 0:
		var moved = try_move_horizontal(new_pos.x)
		if not moved:
			velocity.x = 0
	
	# Vertical collision
	if velocity.y != 0:
		if can_move_to(position.x, new_pos.y):
			position.y = new_pos.y
		else:
			# Snap to surface when landing
			if velocity.y > 0:
				position.y = snap_to_ground(position.x, position.y)
			velocity.y = 0


func try_move_horizontal(new_x: float) -> bool:
	# Try moving straight
	if can_move_to(new_x, position.y):
		position.x = new_x
		return true
	
	# Try stepping up inclines
	for step in range(1, max_step_height + 1):
		var step_y = position.y - step * tile_size
		if can_move_to(new_x, step_y):
			position.x = new_x
			position.y = step_y
			return true
	
	return false


func snap_to_ground(px: float, py: float) -> float:
	# Find the exact ground level
	var cell_y = int(py) / tile_size
	while cell_y < sim.matrix_height and not is_ground_at(px, cell_y):
		cell_y += 1
	return float(cell_y * tile_size)


func is_ground_at(px: float, cell_y: int) -> bool:
	var left = int(px - player_width / 2) / tile_size
	var right = int(px + player_width / 2 - 1) / tile_size
	if left > right:
		right = left
	for x in range(left, right + 1):
		if is_solid(x, cell_y):
			return true
	return false


func is_in_liquid(px: float, py: float) -> bool:
	var left = int(px - player_width / 2) / tile_size
	var right = int(px + player_width / 2 - 1) / tile_size
	var top = int(py - player_height) / tile_size
	var bottom = int(py - 1) / tile_size

	if left > right:
		right = left
	if top > bottom:
		bottom = top

	for x in range(left, right + 1):
		for y in range(top, bottom + 1):
			var cell = sim.get_cell(x, y)
			if cell in Registry.LIQUIDS:
				return true
	return false

func overlaps_solid(px: float, py: float) -> bool:
	# Check the entire player rectangle for any solid tiles
	var left = int(px - player_width / 2) / tile_size
	var right = int(px + player_width / 2 - 1) / tile_size
	var top = int(py - player_height) / tile_size
	var bottom = int(py - 1) / tile_size

	if left > right:
		right = left
	if top > bottom:
		bottom = top

	for x in range(left, right + 1):
		for y in range(top, bottom + 1):
			if is_solid(x, y):
				return true
	return false


func can_move_to(px: float, py: float) -> bool:
	# Use full-rectangle overlap test
	return not overlaps_solid(px, py)


func is_on_ground() -> bool:
	var left = int(position.x - player_width / 2) / tile_size
	var right = int(position.x + player_width / 2 - 1) / tile_size
	var feet_y = int(position.y) / tile_size

	if left > right:
		right = left

	for x in range(left, right + 1):
		if is_solid(x, feet_y):
			return true
	return false


func is_solid(cell_x: int, cell_y: int) -> bool:
	# Treat bottom of world as solid floor
	if cell_y >= sim.matrix_height:
		return true
	var cell = sim.get_cell(cell_x, cell_y)
	# EMPTY and WATER are not solid
	return cell != Registry.elements.EMPTY and cell != Registry.elements.WATER
