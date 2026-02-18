## Main Game Controller, setup, init, ui, and driver

extends Node2D

## Setup
@export var matrix_width: int = 320
@export var matrix_height: int = 180
# Zoom / size of tile in tile map
@export var tile_size: int = 2

@export var brush_size: int = 2

# How many steps of the sim to run per frame
@export var sim_speed: int = 1

## System setup
@onready var sim: Simulation		# Physics
@onready var render: Renderer 		# Appearence
@onready var input: InputHandler 	# Interaction
@onready var player: Player      	# Player character

## UI Setup
var fps_label: Label
var cell_label: Label
var selection_label: Label


## When node is ready / loaded, perform setup
func _ready():
	sim = %Simulation
	sim.initialize(matrix_width, matrix_height)

	render = %Renderer
	render.initialize(matrix_width, matrix_height, tile_size, self)

	input = %InputHandler
	input.initialize(sim, tile_size, brush_size, self)

	player = %Player
	player.initialize(sim, tile_size)
	# add_child(player)

	render.update(sim.matrix)

	setup_ui()


func setup_ui():
	fps_label = %FpsLabel

	cell_label = %CellLabel
	
	selection_label = %SelectionLabel

	update_ui()


func update_ui():
	fps_label.text = "FPS: %d" % Engine.get_frames_per_second()

	cell_label.text = "Cell Count: %d" % sim.cell_count

	selection_label.text = "Element: %d | Brush: %d" % [input.current_element, input.get_brush_size()]


## Main game loop, runs every frame and tracks delta time
func _process(_delta):
	sim.stepAll()
	input.handle_input()

	render.update_dirty(sim.matrix, sim.get_dirty_cells())
	sim.clear_dirty()
	update_ui()
