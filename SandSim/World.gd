## Main Game Controller, setup, init, ui, and driver

extends Node2D

## Setup
@export var grid_width: int = 100
@export var grid_height: int = 100

# Zoom / size of tile in tile map
@export var tile_size: int = 5

@export var brush_size: int = 1

# How many steps of the sim to run per frame
@export var sim_speed: int = 1

## System setup
var sim: Simulation  # Physics
var render: Renderer # Appearence
var input: Input	 # Interaction

## UI Setup
var fps_label: Label
var cell_label: Label
var selection_label: Label

# ...

## When node is ready / loaded, perform setup
func _ready():
	pass

func setup_ui():
	pass

## Main game loop, runs every frame and tracks delta time
func _process(_delta):
	pass

func update_ui():
	pass
