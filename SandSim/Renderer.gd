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
const EMPTY_COORD = Vector2i(0,0)
const WALL_COORD = Vector2i(1,0)
const SAND_COORD = Vector2i(2,0)
const WATER_COORD = Vector2i(3,0)


func init(width: int, height: int, size: int, parent: Node):
	grid_width = width
	grid_height = height
	tile_size = size

	map = TileMapLayer.new()
	map.tile_set = create_tile_set()

	parent.add_child(map)


func create_tile_set() -> TileSet:
	var tile_set = TileSet.new()
	pass
	# Set size of tiles
	tile_set.tile_size = Vector2i(tile_size, tile_size)
	

	var source = TileSetAtlasSource.new()
	source.texture = create_texture_atlas()
	source.texture_region_size = Vector2i(tile_size, tile_size)

	source.create_tile(EMPTY_COORD)
	source.create_tile(WALL_COORD)
	source.create_tile(SAND_COORD)
	source.create_tile(WATER_COORD)

	tile_set.add_source(source, TILE_SOURCE_ID)

	return tile_set


func create_tecture_atlas: -> ImageTexture:
	var atlas_width = tile_size * Registery.elements.length()
	var img = Image.create(atlas_width, tile_size, false, Image.FORMAT_RGBA8)

	for element in elements:
		var pos: int = tile_size * element
		img.fill_rect(Rect2i(pos, 0, tile_size, tile_size), Registery.get_color(element))
	
	return ImageTexture.create_from_image(image)


func update():
	pass


func get_atlas_coord():
	pass
