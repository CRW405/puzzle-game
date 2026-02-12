extends Node2D

 # VERY BASIC SATISFYING SIMULATION MANAGER - Michael (Your welcome I added comments)
# NOTES ~ Elements are not developed yet. Highly optimized for one use case
# 1. Input Manager should be split. As well as UI in future.
# 2. Logic is very dumbed down and will need to be modified and likely
# less optimized as heightmap is static as well as interactions within
# only particles themselves.
# 3. This is built using an ECS (Entity-Component System) inspiration
# mainly for optimization but other code should not be built similarly.
# 4. Modify _particle_size and mesh size within multiMeshInstance2D's multimesh
# if you wanted to change size of particles.
# 5. Ask me if you need clarification.


# Setup 
var _capacity: int = 15000 
var _particle_size: int = 4 # MUST MATCH MESH SIZE
var _screen_height: float = 600.0 
var _screen_width: int = 1152 

# Data
var _count: int = 0
var _positions: PackedVector2Array
var _velocities: PackedVector2Array
var _type_ids: PackedByteArray # 0=Sand, 1=Water, 2=Stone
var _is_stopped: PackedByteArray 

# Heightmap
var _floor_heights: PackedFloat32Array

# color
# Sand (Yellow), Water (Blue), Stone (Dark Gray)
var _colors = [Color.SANDY_BROWN, Color(0.2, 0.6, 1.0), Color.DARK_SLATE_GRAY]

# Nodes
@onready var _renderer: MultiMeshInstance2D = $MultiMeshInstance2D
@onready var _ui_label: Label = $CanvasLayer/StatsLabel

func _ready() -> void:
	# Set arrays
	_positions.resize(_capacity)
	_velocities.resize(_capacity)
	_type_ids.resize(_capacity)
	_is_stopped.resize(_capacity)
	
	# Set Heighjtmap 
	var columns = int(_screen_width / _particle_size) + 1
	_floor_heights.resize(columns)
	_floor_heights.fill(0.0) 

	# Setup Renderer 
	_renderer.multimesh.instance_count = _capacity
	_renderer.multimesh.visible_instance_count = 0 
	
	_screen_height = get_viewport_rect().size.y
	_screen_width = get_viewport_rect().size.x

func _process(delta: float) -> void:
	# Inputs
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		for k in range(5):
			spawn_particle(get_global_mouse_position())
			
	if Input.is_key_pressed(KEY_1): _current_type = 0 # Sand
	if Input.is_key_pressed(KEY_2): _current_type = 1 # Water
	if Input.is_key_pressed(KEY_3): _current_type = 2 # Stone

	# UI
	if _ui_label:
		var names = ["Sand", "Water", "Stone"]
		_ui_label.text = "FPS: %d\nParticles: %d\nElement: %s" % [Engine.get_frames_per_second(), _count, names[_current_type]]

	# start sim 
	var gravity = 980.0 * delta
	var p_size = float(_particle_size)
	var max_col = _floor_heights.size() - 1
	
	for i in range(_count):
		# If idle stop phys
		if _is_stopped[i] == 1:
			_update_render(i)
			continue

		var type = _type_ids[i]
		
		# Stone logic
		if type == 2:
			# Stone falls until it hits floor, then becomes part of the floor
			_velocities[i].y += gravity
			_positions[i] += _velocities[i] * delta
			
			var col = int(_positions[i].x / p_size)
			if col >= 0 and col <= max_col:
				var pile_h = _floor_heights[col]
				var floor_y = _screen_height - pile_h
				
				# Set new floormap
				if _positions[i].y >= floor_y:
					_positions[i].y = floor_y - p_size
					_is_stopped[i] = 1
					_floor_heights[col] += p_size
					_velocities[i] = Vector2.ZERO
			_update_render(i)
			continue

		# Sand water phys
		_velocities[i].y += gravity
		_positions[i] += _velocities[i] * delta
		
		var col = int(_positions[i].x / p_size)
		
		# Check bound
		if col >= 0 and col <= max_col:
			var pile_h = _floor_heights[col]
			var current_floor = _screen_height - pile_h
			
			if _positions[i].y >= current_floor:
				
				var left_h = _floor_heights[col - 1] if col > 0 else 99999.0
				var right_h = _floor_heights[col + 1] if col < max_col else 99999.0
				
				# Water Logic
				if type == 1:
					# Water does not stops if it has somewhere to go
					var moved = false
					
					# Flow
					if col > 0 and left_h < pile_h:
						_positions[i].x -= p_size
						moved = true
					elif col < max_col and right_h < pile_h:
						_positions[i].x += p_size
						moved = true
					
					# If trapped stay
					else:
						_positions[i].y = current_floor - p_size
						_velocities[i] = Vector2.ZERO
						_floor_heights[col] += p_size
						
						#Optimization
						_is_stopped[i] = 1 
						
					if moved:
						_positions[i].y = current_floor - 1 
						_velocities[i].y = 0

				# Sand logic
				else:
					var moved = false
					# Drop if steep
					if col > 0 and left_h < pile_h - p_size:
						_positions[i].x -= p_size
						moved = true
					elif col < max_col and right_h < pile_h - p_size:
						_positions[i].x += p_size
						moved = true
						
					if moved:
						_positions[i].y = current_floor - 1
					else:
						# Stack
						_positions[i].y = current_floor - p_size
						_velocities[i] = Vector2.ZERO
						_is_stopped[i] = 1
						_floor_heights[col] += p_size

		# Clean bottom
		if _positions[i].y > _screen_height + 50:
			_remove_particle(i)
			continue

		_update_render(i)
		
	_renderer.multimesh.visible_instance_count = _count

var _current_type: int = 0

func _update_render(i: int) -> void:
	var t = Transform2D(0.0, _positions[i])
	_renderer.multimesh.set_instance_transform_2d(i, t)

func spawn_particle(pos: Vector2) -> void:
	if _count >= _capacity: return
	_positions[_count] = pos
	_velocities[_count] = Vector2(randf_range(-10, 10), randf_range(-50, -100))
	_is_stopped[_count] = 0 
	_type_ids[_count] = _current_type
	
	# Set Color
	_renderer.multimesh.set_instance_color(_count, _colors[_current_type])
	
	_count += 1

func _remove_particle(index: int) -> void:
	_count -= 1
	if index != _count:
		_positions[index] = _positions[_count]
		_velocities[index] = _velocities[_count]
		_is_stopped[index] = _is_stopped[_count]
		_type_ids[index] = _type_ids[_count]
		# Move Color
		var col = _renderer.multimesh.get_instance_color(_count)
		_renderer.multimesh.set_instance_color(index, col)
