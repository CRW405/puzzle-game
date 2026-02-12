## Main Game Controller, setup, init, ui, and driver

extends Node2D

## Setup
@export var matrix_width: int = 320
@export var matrix_height: int = 180

# Zoom / size of tile in tile map
@export var tile_size: int = 2

@export var brush_size: int = 5

# How many steps of the sim to run per frame
@export var sim_speed: int = 1

## System setup
var sim: Simulation 	# Physics
var render: Renderer 	# Appearence
var input: InputHandler # Interaction

## UI Setup
var fps_label: Label
# var fps: int = 0
var cell_label: Label
# var cell_count: int = 0
var selection_label: Label
# var selection: int = 1

# ...

## When node is ready / loaded, perform setup
func _ready():
	sim = Simulation.new()
	sim.initialize(matrix_width, matrix_height)

	render = Renderer.new()
	render.initialize(matrix_width, matrix_height, tile_size, self)

	input = InputHandler.new()
	input.initialize(sim, tile_size, brush_size, self)

	render.update(sim.matrix)

	setup_ui()


func setup_ui():
	fps_label = Label.new()
	fps_label.position = Vector2(10,10)
	fps_label.add_theme_color_override("font_color", Color.WHITE)
	add_child(fps_label)

	cell_label = Label.new()
	cell_label.position = Vector2(10, 30)
	cell_label.add_theme_color_override("font_color", Color.WHITE)
	add_child(cell_label)
	
	selection_label = Label.new()
	selection_label.position = Vector2(10, 50)
	selection_label.add_theme_color_override("font_color", Color.WHITE)
	add_child(selection_label)

	update_ui()


func update_ui():
	fps_label.text = "FPS: %d" % Engine.get_frames_per_second()

	cell_label.text = "Cell Count: %d" % sim.cell_count

	selection_label.text = "Element: %d" % input.current_element


## Main game loop, runs every frame and tracks delta time
func _process(_delta):
	sim.stepAll()
	input.handle_input()

	render.update(sim.matrix)
	update_ui()
