## WorldTileMap - Main Game Controller
##
## This is the entry point and orchestrator for the entire sand simulation.
## It initializes all subsystems, runs the main game loop, and manages UI display.
##
## Game Loop Flow (each frame):
## 1. Clear dirty cell tracking
## 2. Process user input (marks placed cells as dirty)
## 3. Run physics simulation N times (accumulates more dirty cells)
## 4. Render only the dirty (changed) cells
## 5. Update UI labels
##
## This separation of concerns keeps the code modular and maintainable.

extends Node2D

# Grid dimensions - how many cells in the simulation
@export var grid_width: int = 125
@export var grid_height: int = 125

# Visual size of each cell in pixels
@export var tile_size: int = 3

# Brush radius in cells when placing elements
@export var brush_size: int = 5

# How many physics steps to run per frame (higher = faster simulation)
@export var simulation_speed: int = 2

# Core subsystems - each handles one aspect of the game
var simulation: Simulation          # Physics engine
var renderer: TileMapRenderer       # Visual display
var input_handler: InputHandler     # Mouse/keyboard input

# UI labels for displaying stats
var fps_label: Label
var cell_label: Label
var element_label: Label

# Cached values to avoid updating labels every frame
var last_fps: int = 0
var last_cell_count: int = 0
var last_element: int = -1

## Called when the node enters the scene tree
## Initializes all subsystems in the correct order
func _ready():
	# Create and initialize the physics simulation
	# This sets up the grid data structure
	simulation = Simulation.new()
	simulation.initialize(grid_width, grid_height)
	
	# Create and initialize the visual renderer
	# This creates the tilemap and texture atlas
	renderer = TileMapRenderer.new()
	renderer.initialize(grid_width, grid_height, tile_size, self)
	
	# Create and initialize input handling
	# This sets up mouse/keyboard controls
	input_handler = InputHandler.new()
	input_handler.initialize(simulation, tile_size, brush_size, self)
	
	# Do initial render of the empty grid
	renderer.update(simulation.grid)
	
	# Create UI labels for stats display
	setup_ui()

## Creates the UI labels that display game stats
## These are positioned in the top-left corner
func setup_ui():
	# FPS counter - shows current frames per second
	fps_label = Label.new()
	fps_label.position = Vector2(10, 10)
	fps_label.add_theme_color_override("font_color", Color.WHITE)
	add_child(fps_label)
	
	# Cell counter - shows how many non-empty cells exist
	cell_label = Label.new()
	cell_label.position = Vector2(10, 30)
	cell_label.add_theme_color_override("font_color", Color.WHITE)
	add_child(cell_label)
	
	# Element selector - shows which element is currently selected
	element_label = Label.new()
	element_label.position = Vector2(10, 50)
	element_label.add_theme_color_override("font_color", Color.WHITE)
	add_child(element_label)

## Main game loop - called every frame
## The order of operations is critical for proper dirty cell tracking
func _process(_delta):
	# Clear dirty cells at start of frame
	# Dirty cells = cells that changed and need re-rendering
	simulation.dirty_cells.clear()
	
	# Handle input (marks placed cells as dirty)
	# User can place or erase elements with mouse
	input_handler.handle_input()
	
	# Run simulation steps (accumulates dirty cells)
	# Multiple steps per frame make the simulation run faster
	for i in range(simulation_speed):
		simulation.step_without_clear()
	
	# Render all dirty cells from this frame
	# Only changed cells are redrawn for performance
	renderer.update(simulation.grid, simulation.get_dirty_cells())
	
	# Update UI labels if values changed
	update_ui()

## Updates UI labels only when values change
## This avoids string operations every frame for better performance
func update_ui():
	# Update FPS display
	var current_fps = Engine.get_frames_per_second()
	if current_fps != last_fps:
		fps_label.text = "FPS: %d" % current_fps
		last_fps = current_fps
	
	# Update cell count display
	# This uses a cached counter, not a grid scan
	var count = simulation.count_cells()
	if count != last_cell_count:
		cell_label.text = "Cells: %d" % count
		last_cell_count = count
	
	# Update current element display
	var current_element = input_handler.get_current_element()
	if current_element != last_element:
		var element_name = ElementTypes.get_element_name(current_element)
		element_label.text = "Element: %s (1-3)" % element_name
		last_element = current_element
