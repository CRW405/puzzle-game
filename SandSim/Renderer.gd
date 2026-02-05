## Main renderer, displays the sim as tiles on a tilemaplayer

extends Node
class_name Renderer

## Tile Map Setup
var map: TileMapLayer

var grid_width: int
var grid_height: int

# size of tiles in pixels
var tile_size: int

## Tile set setup
## This is for a tile set that controls the look of the displayed elements
const TILE_SOURCE_ID = 0
#const <ELEMENT>ATLAS_COORD = Vector2i(<i>, 0) # How to add new tile


func init():
	pass


func create_tile_set() -> TileSet:
	pass


func create_tecture_atlas: -> ImageTexture:
	pass


func update():
	pass

func get_atlas_coord():
	pass
