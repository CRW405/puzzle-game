

## Player character - pixel-based movement with matrix collision
## Just for proof of concept, this will not the be the final player controller, just something quick for a frame of reference
extends Node2D
class_name Player

## Movement settings
@export var move_speed: float = 60.0
@export var gravity: float = 200.0
@export var jump_velocity: float = -120.0
@export var max_step_height: int = 2  # Max cells player can step up

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
	
	handle_input()
	apply_gravity(delta)
	move(delta)


func handle_input():
	var input_dir = 0
	if Input.is_action_pressed("ui_left") || Input.is_key_pressed(KEY_A):
		input_dir -= 1
	if Input.is_action_pressed("ui_right") || Input.is_key_pressed(KEY_D):
		input_dir += 1
	
	velocity.x = input_dir * move_speed
	
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
	return is_solid(left, cell_y) or is_solid(right, cell_y)


func can_move_to(px: float, py: float) -> bool:
	# Check all corners of player hitbox against matrix
	var left = int(px - player_width / 2) / tile_size
	var right = int(px + player_width / 2 - 1) / tile_size
	var top = int(py - player_height) / tile_size
	var bottom = int(py - 1) / tile_size
	
	# Check each corner
	if is_solid(left, top) or is_solid(right, top):
		return false
	if is_solid(left, bottom) or is_solid(right, bottom):
		return false
	
	return true


func is_on_ground() -> bool:
	var left = int(position.x - player_width / 2) / tile_size
	var right = int(position.x + player_width / 2 - 1) / tile_size
	var feet_y = int(position.y) / tile_size
	
	return is_solid(left, feet_y) or is_solid(right, feet_y)


func is_solid(cell_x: int, cell_y: int) -> bool:
	# Treat bottom of world as solid floor
	if cell_y >= sim.matrix_height:
		return true
	var cell = sim.get_cell(cell_x, cell_y)
	# EMPTY and WATER are not solid
	return cell != Registry.elements.EMPTY and cell != Registry.elements.WATER
