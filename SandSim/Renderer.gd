## Main renderer, displays the sim as tiles on a tilemaplayer

extends Node2D
class_name Renderer

## Tile Map Setup
var map: TileMapLayer

var matrix_width: int
var matrix_height: int

# size of tiles in pixels
var tile_size: int

## Tile set setup
## This is for a tile set that controls the look of the displayed elements
const TILE_SOURCE_ID = 0
const EMPTY_COORD = Vector2i(0,0)
const WALL_COORD = Vector2i(1,0)
const SAND_COORD = Vector2i(2,0)
const WATER_COORD = Vector2i(3,0)


func initialize(width: int, height: int, size: int, parent: Node):
	matrix_width = width
	matrix_height = height
	tile_size = size

	map = %SimTileMapLayer
	map.tile_set = create_tile_set()


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


func create_texture_atlas() -> ImageTexture:
	var atlas_width = tile_size * Registry.elements.size()
	var img = Image.create(atlas_width, tile_size, false, Image.FORMAT_RGBA8)

	for element in range(Registry.elements.size()):
		var pos: int = tile_size * element
		img.fill_rect(Rect2i(pos, 0, tile_size, tile_size), Registry.get_color(element))
	
	return ImageTexture.create_from_image(img)


func update(matrix: PackedInt32Array):
	for y in range(matrix_height):
		for x in range(matrix_width):
			var atlas_coord = get_atlas_coord(matrix[y * matrix_width + x])
			map.set_cell(Vector2i(x,y), TILE_SOURCE_ID, atlas_coord)


func update_dirty(matrix: PackedInt32Array, dirty_cells: PackedByteArray):
	for idx in range(dirty_cells.size()):
		if dirty_cells[idx] == 1:
			var x = idx % matrix_width
			var y = idx / matrix_width
			var atlas_coord = get_atlas_coord(matrix[idx])
			map.set_cell(Vector2i(x, y), TILE_SOURCE_ID, atlas_coord)


func get_atlas_coord(cell: int):
	match cell:
		Registry.elements.EMPTY:
			return EMPTY_COORD
		Registry.elements.SAND:
			return SAND_COORD
		Registry.elements.WALL:
			return WALL_COORD
		Registry.elements.WATER:
			return WATER_COORD
		_:  # Default fallback for unknown types which should be impossible anyways
			return EMPTY_COORD
