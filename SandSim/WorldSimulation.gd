extends Node2D

# Config
const WIDTH = 640
const HEIGHT = 360
const SCALE = 4

# Elements
const EL_AIR   = 0
const EL_SAND  = 1
const EL_WATER = 2
const EL_STONE = 3
const EL_WOOD  = 4
const EL_FIRE  = 5
const EL_SMOKE = 6
const EL_STEAM = 7
const EL_ASH   = 8

# ElementInfo stored as dictionaries
var _elements: Array = []

# Reactions table [9][9], -1 means no reaction
var _reactions: Array = []

# Grid data
var _grid: Array = []
var _particle_count: int = 0

var _image: Image
var _texture: ImageTexture
var _sprite: Sprite2D
var _ui_label: Label
var _current_tool: int = EL_SAND

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()
	_setup_database()
	_grid = []
	_grid.resize(WIDTH * HEIGHT)
	_grid.fill(EL_AIR)

	_image = Image.create(WIDTH, HEIGHT, false, Image.FORMAT_RGBA8)
	_texture = ImageTexture.create_from_image(_image)

	_sprite = Sprite2D.new()
	_sprite.texture = _texture
	_sprite.scale = Vector2(SCALE, SCALE)
	_sprite.centered = false
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(_sprite)

	_setup_ui()


func _process(_delta: float) -> void:
	_handle_input()
	_simulate()
	_render()
	_update_ui()


func _setup_ui() -> void:
	var cl := CanvasLayer.new()
	add_child(cl)
	_ui_label = Label.new()
	_ui_label.position = Vector2(10, 10)
	_ui_label.modulate = Color.WHITE
	_ui_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_ui_label.add_theme_constant_override("outline_size", 4)
	cl.add_child(_ui_label)


func _update_ui() -> void:
	var tool_name: String = _elements[_current_tool]["name"]
	_ui_label.text = "FPS: %d\nParticles: %d\nTool: %s (1-5)" % [
		Engine.get_frames_per_second(),
		_particle_count,
		tool_name
	]


func _setup_database() -> void:
	_elements.resize(9)

	_elements[EL_AIR]   = { "name": "Air",   "is_solid": false, "is_liquid": false, "is_gas": false, "density": 0,    "burning_chance": 0.0,  "base_color": Color.BLACK }
	_elements[EL_SAND]  = { "name": "Sand",  "is_solid": false, "is_liquid": false, "is_gas": false, "density": 10,   "burning_chance": 0.0,  "base_color": Color("#e6c229") }
	_elements[EL_WATER] = { "name": "Water", "is_solid": false, "is_liquid": true,  "is_gas": false, "density": 5,    "burning_chance": 0.0,  "base_color": Color("#1ca3ec") }
	_elements[EL_STONE] = { "name": "Stone", "is_solid": true,  "is_liquid": false, "is_gas": false, "density": 100,  "burning_chance": 0.0,  "base_color": Color("#4a4a4a") }
	_elements[EL_WOOD]  = { "name": "Wood",  "is_solid": true,  "is_liquid": false, "is_gas": false, "density": 50,   "burning_chance": 0.05, "base_color": Color("#6d4c41") }
	_elements[EL_FIRE]  = { "name": "Fire",  "is_solid": false, "is_liquid": false, "is_gas": true,  "density": -1,   "burning_chance": 0.2,  "base_color": Color("#ff5722") }
	_elements[EL_SMOKE] = { "name": "Smoke", "is_solid": false, "is_liquid": false, "is_gas": true,  "density": -2,   "burning_chance": 0.0,  "base_color": Color("#757575") }
	_elements[EL_STEAM] = { "name": "Steam", "is_solid": false, "is_liquid": false, "is_gas": true,  "density": -2,   "burning_chance": 0.0,  "base_color": Color("#cfd8dc") }
	_elements[EL_ASH]   = { "name": "Ash",   "is_solid": false, "is_liquid": false, "is_gas": false, "density": 15,   "burning_chance": 0.0,  "base_color": Color("#212121") }

	# Init reactions table
	_reactions = []
	_reactions.resize(9)
	for i in range(9):
		_reactions[i] = []
		_reactions[i].resize(9)
		for j in range(9):
			_reactions[i][j] = -1

	# Fire logic
	_reactions[EL_FIRE][EL_WOOD]  = EL_FIRE   # Fire spreads to Wood
	_reactions[EL_FIRE][EL_WATER] = EL_STEAM  # Water boils
	_reactions[EL_WATER][EL_FIRE] = EL_STEAM  # Fire extinguished


func _handle_input() -> void:
	if Input.is_key_pressed(KEY_1): _current_tool = EL_SAND
	if Input.is_key_pressed(KEY_2): _current_tool = EL_WATER
	if Input.is_key_pressed(KEY_3): _current_tool = EL_WOOD
	if Input.is_key_pressed(KEY_4): _current_tool = EL_FIRE
	if Input.is_key_pressed(KEY_5): _current_tool = EL_STONE

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var m_pos: Vector2 = get_local_mouse_position() / SCALE
		_paint(int(m_pos.x), int(m_pos.y), _current_tool, 2)


func _simulate() -> void:
	# Rising elements (Fire, Smoke, Steam) — top-down
	for y in range(HEIGHT):
		_process_row(y, true)

	# Falling elements (Sand, Water, Ash) — bottom-up
	for y in range(HEIGHT - 1, -1, -1):
		_process_row(y, false)


func _process_row(y: int, process_rising: bool) -> void:
	var left_to_right: bool = _rng.randi() % 2 == 0
	var start_x: int = 0 if left_to_right else WIDTH - 1
	var end_x: int   = WIDTH if left_to_right else -1
	var step: int    = 1 if left_to_right else -1

	var x := start_x
	while x != end_x:
		var i: int = y * WIDTH + x
		var type: int = _grid[i]

		if type == EL_AIR or _elements[type]["is_solid"]:
			x += step
			continue

		var is_gas: bool = _elements[type]["is_gas"]
		if process_rising and not is_gas:
			x += step
			continue
		if not process_rising and is_gas:
			x += step
			continue

		# Lifetime decay for gas (fire/smoke)
		if is_gas and _rng.randf() < 0.04:
			_change_pixel(i, EL_AIR)
			if type == EL_FIRE:
				_change_pixel(i, EL_SMOKE)
			x += step
			continue

		# Reactions
		if _try_react(i, x, y, 0, 1):
			x += step
			continue
		if _try_react(i, x, y, 0, -1):
			x += step
			continue
		if _try_react(i, x, y, -1, 0):
			x += step
			continue
		if _try_react(i, x, y, 1, 0):
			x += step
			continue

		# Movement
		var gravity_dir: int = -1 if is_gas else 1

		if _try_move(i, x, y, 0, gravity_dir, type):
			x += step
			continue
		if _try_move(i, x, y, -1, gravity_dir, type):
			x += step
			continue
		if _try_move(i, x, y, 1, gravity_dir, type):
			x += step
			continue

		if _elements[type]["is_liquid"] or is_gas:
			if _try_move(i, x, y, -1, 0, type):
				x += step
				continue
			if _try_move(i, x, y, 1, 0, type):
				x += step
				continue

		x += step


func _change_pixel(index: int, new_type: int) -> void:
	var old_type: int = _grid[index]
	if old_type == EL_AIR and new_type != EL_AIR:
		_particle_count += 1
	elif old_type != EL_AIR and new_type == EL_AIR:
		_particle_count -= 1
	_grid[index] = new_type


func _try_move(i: int, x: int, y: int, dx: int, dy: int, type: int) -> bool:
	var nx := x + dx
	var ny := y + dy

	if nx < 0 or nx >= WIDTH or ny < 0 or ny >= HEIGHT:
		return false

	var ni: int = ny * WIDTH + nx
	var neighbor: int = _grid[ni]

	# Fire doesn't move into wood (it reacts instead)
	if type == EL_FIRE and neighbor == EL_WOOD:
		return false

	var can_move := false

	if neighbor == EL_AIR:
		can_move = true
	elif _elements[type]["is_gas"] and not _elements[neighbor]["is_solid"]:
		can_move = true  # Gas rises through liquids/sand
	elif (
		_elements[type]["density"] > _elements[neighbor]["density"]
		and not _elements[neighbor]["is_solid"]
		and not _elements[neighbor]["is_gas"]
	):
		can_move = true  # Sink down

	if can_move:
		_grid[ni] = type
		_grid[i] = neighbor
		return true

	return false


func _try_react(i: int, x: int, y: int, dx: int, dy: int) -> bool:
	var nx := x + dx
	var ny := y + dy

	if nx < 0 or nx >= WIDTH or ny < 0 or ny >= HEIGHT:
		return false

	var ni: int = ny * WIDTH + nx
	var my_type: int = _grid[i]
	var neighbor: int = _grid[ni]

	if neighbor == EL_AIR:
		return false

	var result: int = _reactions[my_type][neighbor]
	if result != -1:
		var burning_chance: float = _elements[my_type]["burning_chance"]
		if burning_chance > 0.0 and _rng.randf() > burning_chance:
			return false
		_change_pixel(ni, result)
		if my_type == EL_FIRE and neighbor == EL_WOOD and _rng.randf() < 0.1:
			_change_pixel(ni, EL_ASH)
		return true

	return false


func _paint(cx: int, cy: int, type: int, r: int) -> void:
	for dy in range(-r, r + 1):
		for dx in range(-r, r + 1):
			if dx * dx + dy * dy <= r * r:
				var px := cx + dx
				var py := cy + dy
				if px >= 0 and px < WIDTH and py >= 0 and py < HEIGHT:
					if _grid[py * WIDTH + px] != EL_STONE:
						_change_pixel(py * WIDTH + px, type)


func _render() -> void:
	for i in range(_grid.size()):
		var type: int = _grid[i]
		var x: int = i % WIDTH
		var y: int = i / WIDTH

		if type == EL_AIR:
			_image.set_pixel(x, y, Color.BLACK)
			continue

		# Deterministic noise based on position
		var noise: float = float((x * 2341 + y * 4231) % 100) / 100.0
		var base_color: Color = _elements[type]["base_color"]
		var final_color: Color = base_color

		match type:
			EL_STONE:
				final_color = base_color.darkened(noise * 0.2)
			EL_SAND, EL_WOOD, EL_ASH:
				final_color = base_color.lightened((noise - 0.5) * 0.1)
			EL_WATER:
				final_color = base_color.lightened(noise * 0.1)
			EL_FIRE:
				var flicker: float = _rng.randf()
				if flicker > 0.6:
					final_color = Color.YELLOW
				elif flicker > 0.3:
					final_color = Color.ORANGE
				else:
					final_color = Color.RED
			EL_SMOKE, EL_STEAM:
				final_color = base_color.darkened(_rng.randf() * 0.1)

		_image.set_pixel(x, y, final_color)

	_texture.update(_image)
