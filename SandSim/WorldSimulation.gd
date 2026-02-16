extends Node2D
class_name WorldSimulation

# Config
const WIDTH: int = 256
const HEIGHT: int = 150
const SCALE_FACTOR: int = 4

# Elements
const EL_AIR: int = 0
const EL_SAND: int = 1
const EL_WATER: int = 2
const EL_STONE: int = 3
const EL_WOOD: int = 4
const EL_FIRE: int = 5
const EL_SMOKE: int = 6
const EL_STEAM: int = 7
const EL_ASH: int = 8

var _elements: Array[Dictionary] = []
var _reactions: PackedInt32Array

# Data
var _grid: PackedInt32Array
var _particle_count: int = 0

# Nodes & Resources
var _image: Image
var _texture: ImageTexture
var _sprite: Sprite2D
var _ui_label: Label
var _current_tool: int = EL_SAND

func _ready() -> void:
	setup_database()
	
	_grid = PackedInt32Array()
	_grid.resize(WIDTH * HEIGHT)
	_grid.fill(EL_AIR)
	
	_image = Image.create(WIDTH, HEIGHT, false, Image.FORMAT_RGBA8)
	_texture = ImageTexture.create_from_image(_image)
	
	_sprite = Sprite2D.new()
	_sprite.texture = _texture
	_sprite.scale = Vector2(SCALE_FACTOR, SCALE_FACTOR)
	_sprite.centered = false
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(_sprite)
	
	setup_ui()

# Main Process Thread
func _process(_delta: float) -> void:
	handle_input()
	simulate()
	render()
	update_ui()

func setup_ui() -> void:
	var cl = CanvasLayer.new()
	add_child(cl)
	_ui_label = Label.new()
	_ui_label.position = Vector2(10, 10)
	_ui_label.modulate = Color.WHITE
	_ui_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_ui_label.add_theme_constant_override("outline_size", 4)
	cl.add_child(_ui_label)

func update_ui() -> void:
	var tool_name = _elements[_current_tool].name
	_ui_label.text = "FPS: %d\nParticles: %d\nTool: %s (1-5)" % [
		Engine.get_frames_per_second(),
		_particle_count,
		tool_name
	]
	
# Helper lambda to generate default element dictionaries
func make_el(n: String, c: Color, d: int, s: bool=false, l: bool=false, g: bool=false, b: float=0.0) -> Dictionary:
	return {
		"name": n, "base_color": c, "density": d,
		"is_solid": s, "is_liquid": l, "is_gas": g, "burning_chance": b
	}

func setup_database() -> void:
	_elements.resize(9)
	
	
	
	_elements[EL_AIR]   = make_el("Air", Color.BLACK, 0)
	_elements[EL_STONE] = make_el("Stone", Color("#4a4a4a"), 100, true)
	_elements[EL_WOOD]  = make_el("Wood", Color("#6d4c41"), 50, true, false, false, 0.05)
	_elements[EL_ASH]   = make_el("Ash", Color("#212121"), 15)
	_elements[EL_SAND]  = make_el("Sand", Color("#e6c229"), 10)
	_elements[EL_WATER] = make_el("Water", Color("#1ca3ec"), 5, false, true)
	_elements[EL_FIRE]  = make_el("Fire", Color("#ff5722"), -1, false, false, true, 0.2)
	_elements[EL_SMOKE] = make_el("Smoke", Color("#757575"), -2, false, false, true)
	_elements[EL_STEAM] = make_el("Steam", Color("#cfd8dc"), -2, false, false, true)
	
	# Set Interactions (Flattened 9x9 2D array into a 1D PackedInt32Array for performance)
	_reactions = PackedInt32Array()
	_reactions.resize(9 * 9)
	_reactions.fill(-1)
	
	# FIRE LOGIC (Formula for 2D to 1D index: y * width + x)
	_reactions[EL_FIRE * 9 + EL_WOOD] = EL_FIRE  # Fire spreads to Wood
	_reactions[EL_FIRE * 9 + EL_WATER] = EL_STEAM # Water boils
	_reactions[EL_WATER * 9 + EL_FIRE] = EL_STEAM # Fire extinguished

func handle_input() -> void:
	if Input.is_key_pressed(KEY_1): _current_tool = EL_SAND
	if Input.is_key_pressed(KEY_2): _current_tool = EL_WATER
	if Input.is_key_pressed(KEY_3): _current_tool = EL_WOOD
	if Input.is_key_pressed(KEY_4): _current_tool = EL_FIRE
	if Input.is_key_pressed(KEY_5): _current_tool = EL_STONE

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var m_pos = get_local_mouse_position() / SCALE_FACTOR
		paint(int(m_pos.x), int(m_pos.y), _current_tool, 2)

func simulate() -> void:
	# Rising elements
	for y in range(HEIGHT):
		process_row(y, true)

	# Dropping elements
	for y in range(HEIGHT - 1, -1, -1):
		process_row(y, false)

func process_row(y: int, process_rising: bool) -> void:
	var left_to_right: bool = (randi() % 2) == 0
	
	# Pythonic way to handle reverse iteration natively in GDScript
	var xs = range(WIDTH) if left_to_right else range(WIDTH - 1, -1, -1)
	
	for x in xs:
		var i = y * WIDTH + x
		var type = _grid[i]
		
		if type == EL_AIR or _elements[type].is_solid: continue
		
		var is_gas: bool = _elements[type].is_gas
		if process_rising and not is_gas: continue
		if not process_rising and is_gas: continue
		
		# Lifetime (Fire and smoke)
		if is_gas and randf() < 0.04:
			change_pixel(i, EL_AIR)
			if type == EL_FIRE:
				change_pixel(i, EL_SMOKE)
			continue
			
		# Check for reactions
		if try_react(i, x, y, 0, 1): continue
		if try_react(i, x, y, 0, -1): continue
		if try_react(i, x, y, -1, 0): continue
		if try_react(i, x, y, 1, 0): continue
		
		# Movement
		var gravity_dir: int = -1 if is_gas else 1
		
		if try_move(i, x, y, 0, gravity_dir, type): continue
		if try_move(i, x, y, -1, gravity_dir, type): continue
		if try_move(i, x, y, 1, gravity_dir, type): continue
		
		if _elements[type].is_liquid or is_gas:
			if try_move(i, x, y, -1, 0, type): continue
			if try_move(i, x, y, 1, 0, type): continue

func change_pixel(index: int, new_type: int) -> void:
	var old_type = _grid[index]
	if old_type == EL_AIR and new_type != EL_AIR:
		_particle_count += 1
	elif old_type != EL_AIR and new_type == EL_AIR:
		_particle_count -= 1
		
	_grid[index] = new_type

func try_move(i: int, x: int, y: int, dx: int, dy: int, type: int) -> bool:
	var nx = x + dx
	var ny = y + dy
	
	if nx < 0 or nx >= WIDTH or ny < 0 or ny >= HEIGHT: 
		return false
		
	var ni = ny * WIDTH + nx
	var neighbor = _grid[ni]
	var can_move = false
	
	# Fire burns through and moves inside wood
	if type == EL_FIRE and neighbor == EL_WOOD: 
		return false
		
	if neighbor == EL_AIR:
		can_move = true
	elif _elements[type].is_gas and not _elements[neighbor].is_solid:
		can_move = true
	elif _elements[type].density > _elements[neighbor].density and not _elements[neighbor].is_solid and not _elements[neighbor].is_gas:
		can_move = true
		
	if can_move:
		_grid[ni] = type
		_grid[i] = neighbor
		return true
		
	return false

func try_react(i: int, x: int, y: int, dx: int, dy: int) -> bool:
	var nx = x + dx
	var ny = y + dy
	if nx < 0 or nx >= WIDTH or ny < 0 or ny >= HEIGHT: 
		return false
		
	var ni = ny * WIDTH + nx
	var my_type = _grid[i]
	var neighbor = _grid[ni]
	
	if neighbor == EL_AIR: 
		return false
		
	# Fetching from our flattened 1D reactions array
	var result = _reactions[my_type * 9 + neighbor]
	if result != -1:
		if _elements[my_type].burning_chance > 0 and randf() > _elements[my_type].burning_chance: 
			return false
			
		change_pixel(ni, result)
		
		if my_type == EL_FIRE and neighbor == EL_WOOD and randf() < 0.1:
			change_pixel(ni, EL_ASH)
			
		return true
		
	return false

func paint(cx: int, cy: int, type: int, r: int) -> void:
	for y in range(-r, r + 1):
		for x in range(-r, r + 1):
			if x*x + y*y <= r*r:
				var px = cx + x
				var py = cy + y
				if px >= 0 and px < WIDTH and py >= 0 and py < HEIGHT:
					if _grid[py * WIDTH + px] != EL_STONE:
						change_pixel(py * WIDTH + px, type)

func render() -> void:
	for i in range(_grid.size()):
		var type = _grid[i]
		if type == EL_AIR:
			_image.set_pixel(i % WIDTH, i / WIDTH, Color.BLACK)
			continue
			
		var x = i % WIDTH
		var y = i / WIDTH
		
		# A simple pseudo-random hash function for dithering
		var noise: float = ((x * 2341 + y * 4231) % 100) / 100.0
		
		var base_color: Color = _elements[type].base_color
		var final_color: Color = base_color
		
		if type == EL_STONE:
			final_color = base_color.darkened(noise * 0.2)
		elif type == EL_SAND or type == EL_WOOD or type == EL_ASH:
			final_color = base_color.lightened((noise - 0.5) * 0.1)
		elif type == EL_WATER:
			final_color = base_color.lightened(noise * 0.1)
		elif type == EL_FIRE:
			var flicker: float = randf()
			if flicker > 0.6: final_color = Color.YELLOW
			elif flicker > 0.3: final_color = Color.ORANGE
			else: final_color = Color.RED
		elif type == EL_SMOKE or type == EL_STEAM:
			final_color = base_color.darkened(randf() * 0.1)
			
		_image.set_pixel(x, y, final_color)
		
	_texture.update(_image)
