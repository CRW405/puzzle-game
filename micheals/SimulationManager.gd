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
var _capacity: int = 40_000
var _particle_size: int = 1
var _screen_height: float = 1080.0
var _screen_width: int = 1920

# Data
# ~ PACKEDVECTORS are much more efficient than normal
# GDSCRIPT vectors as they are typed and optimized.
var _count: int = 0
var _positions: PackedVector2Array
var _velocities: PackedVector2Array
var _lifetimes: PackedFloat32Array
var _is_stopped: PackedByteArray 

# Heightmap
var _floor_heights: PackedFloat32Array

# Nodes
@onready var _renderer: MultiMeshInstance2D = $MultiMeshInstance2D
@onready var _ui_label: Label = $CanvasLayer/StatsLabel

func _ready() -> void:
	# Set Limits
	_positions.resize(_capacity)
	_velocities.resize(_capacity)
	_lifetimes.resize(_capacity)
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
	# Input Manager
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		for k in range(5):
			spawn_particle(get_global_mouse_position())


	# FPS UI
	if _ui_label:
		_ui_label.text = "FPS: %d\nParticles: %d" % [Engine.get_frames_per_second(), _count]

	# start sim
	var gravity = 980.0 * delta
	var particle_w = float(_particle_size)
	var columns_max = _floor_heights.size() - 1
	
	for i in range(_count):
		# updates moving particles only.
		if _is_stopped[i] == 0:
			_velocities[i].y += gravity
			_positions[i] += _velocities[i] * delta
			
			# Map is dependant on columns for sliding particles.
			var col = int(_positions[i].x / particle_w)
			
			# Bound check
			if col >= 0 and col <= columns_max:
				var pile_height = _floor_heights[col]
				var current_floor_y = _screen_height - pile_height
				
				if _positions[i].y >= current_floor_y:
					
					# Cascading logic (sand falling left/right)
					var left_pile = _floor_heights[col - 1] if col > 0 else 99999.0
					var right_pile = _floor_heights[col + 1] if col < columns_max else 99999.0
					
					# Check neighboring pile height to slide or shift particle.
					if col > 0 and left_pile < pile_height - particle_w:
						_positions[i].x -= particle_w
						# Prevent clipping
						_positions[i].y = current_floor_y - 1 
						
					# Slide right
					elif col < columns_max and right_pile < pile_height - particle_w:
						_positions[i].x += particle_w
						_positions[i].y = current_floor_y - 1
						
					# If not cascadable
					else:
						_positions[i].y = current_floor_y - particle_w
						_velocities[i] = Vector2.ZERO
						_is_stopped[i] = 1 
						
						_floor_heights[col] += particle_w
			# Cascade end

			# Boundary check
			if _positions[i].y > _screen_height + 50:
				_remove_particle(i)
				continue

		# Update Mesh Renderer
		var t = Transform2D(0.0, _positions[i])
		_renderer.multimesh.set_instance_transform_2d(i, t)
		
	_renderer.multimesh.visible_instance_count = _count

# Spawns particle with input pos
func spawn_particle(pos: Vector2) -> void:
	if _count >= _capacity: return
	
	_positions[_count] = pos
	_velocities[_count] = Vector2(randf_range(-20, 20), randf_range(-100, -200))
	_is_stopped[_count] = 0 
	_count += 1

# Removes particle based on index of arr.
func _remove_particle(index: int) -> void:
	_count -= 1
	if index != _count:
		_positions[index] = _positions[_count]
		_velocities[index] = _velocities[_count]
		_is_stopped[index] = _is_stopped[_count]
