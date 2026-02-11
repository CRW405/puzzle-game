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
var sim: Simulation  # Physics
var render: Renderer # Appearence
var input: InputHandler	 # Interaction

## UI Setup
var fps_label: Label
var cell_label: Label
var selection_label: Label

# ...

## When node is ready / loaded, perform setup
func _ready():
	sim = Simulation.new(matrix_width, matrix_height)

	render = Renderer.new(matrix_width, matrix_height, tile_size, self)

	input = InputHandler.new(sim, tile_size, brush_size, self)

	render.update(sim.matrix)

func setup_ui():
	pass

## Main game loop, runs every frame and tracks delta time
func _process(_delta):
	sim.stepAll()
	input.handle_input()

	render.update(sim.matrix)

func update_ui():
	pass
