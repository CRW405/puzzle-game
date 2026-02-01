extends Node2D

@export var grid_width: int = 128
@export var grid_height: int = 128
@export var tile_size: int = 5
@export var brush_size: int = 3
@export var simulation_speed: int = 2

var simulation: Simulation
var renderer: TileMapRenderer
var input_handler: InputHandler
var fps_label: Label
var cell_label: Label
var element_label: Label

func _ready():
	simulation = Simulation.new()
	simulation.initialize(grid_width, grid_height)
	
	renderer = TileMapRenderer.new()
	renderer.initialize(grid_width, grid_height, tile_size, self)
	
	input_handler = InputHandler.new()
	input_handler.initialize(simulation, tile_size, brush_size, self)
	
	renderer.update(simulation.grid)
	
	setup_ui()

func setup_ui():
	fps_label = Label.new()
	fps_label.position = Vector2(10, 10)
	fps_label.add_theme_color_override("font_color", Color.WHITE)
	add_child(fps_label)
	
	cell_label = Label.new()
	cell_label.position = Vector2(10, 30)
	cell_label.add_theme_color_override("font_color", Color.WHITE)
	add_child(cell_label)
	
	element_label = Label.new()
	element_label.position = Vector2(10, 50)
	element_label.add_theme_color_override("font_color", Color.WHITE)
	add_child(element_label)

func _process(_delta):
	input_handler.handle_input()
	
	for i in range(simulation_speed):
		simulation.step()
	
	renderer.update(simulation.grid)
	update_ui()

func update_ui():
	fps_label.text = "FPS: %d" % Engine.get_frames_per_second()
	
	var count = simulation.count_cells()
	cell_label.text = "Cells: %d" % count
	
	var element_name = ElementTypes.get_element_name(input_handler.get_current_element())
	element_label.text = "Element: %s (1-3)" % element_name
