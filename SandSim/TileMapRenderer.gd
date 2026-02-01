extends Node
class_name TileMapRenderer

var tile_map: TileMapLayer
var grid_width: int
var grid_height: int
var tile_size: int

const TILE_SOURCE_ID = 0
const EMPTY_ATLAS_COORD = Vector2i(0, 0)
const SAND_ATLAS_COORD = Vector2i(1, 0)
const WALL_ATLAS_COORD = Vector2i(2, 0)
const WATER_ATLAS_COORD = Vector2i(3, 0)

func initialize(width: int, height: int, tile_sz: int, parent: Node):
	grid_width = width
	grid_height = height
	tile_size = tile_sz
	
	tile_map = TileMapLayer.new()
	tile_map.tile_set = create_tile_set()
	parent.add_child(tile_map)

func create_tile_set() -> TileSet:
	var tile_set = TileSet.new()
	tile_set.tile_size = Vector2i(tile_size, tile_size)
	
	var source = TileSetAtlasSource.new()
	source.texture = create_texture_atlas()
	source.texture_region_size = Vector2i(tile_size, tile_size)
	
	# Add tiles for each element type
	source.create_tile(EMPTY_ATLAS_COORD)
	source.create_tile(SAND_ATLAS_COORD)
	source.create_tile(WALL_ATLAS_COORD)
	source.create_tile(WATER_ATLAS_COORD)
	
	tile_set.add_source(source, TILE_SOURCE_ID)
	
	return tile_set

func create_texture_atlas() -> ImageTexture:
	# Create a simple 4x1 atlas with colored squares
	var atlas_width = tile_size * 4
	var atlas_height = tile_size
	var image = Image.create(atlas_width, atlas_height, false, Image.FORMAT_RGBA8)
	
	# Fill EMPTY tile (black)
	image.fill_rect(Rect2i(0, 0, tile_size, tile_size), Color.BLACK)
	
	# Fill SAND tile (yellow)
	image.fill_rect(Rect2i(tile_size, 0, tile_size, tile_size), Color.YELLOW)
	
	# Fill WALL tile (gray)
	image.fill_rect(Rect2i(tile_size * 2, 0, tile_size, tile_size), Color.GRAY)
	
	# Fill WATER tile (dodger blue)
	image.fill_rect(Rect2i(tile_size * 3, 0, tile_size, tile_size), Color.DODGER_BLUE)
	
	return ImageTexture.create_from_image(image)

func update(grid: Array):
	for y in range(grid_height):
		for x in range(grid_width):
			var atlas_coord = get_atlas_coord_for_element(grid[y][x])
			tile_map.set_cell(Vector2i(x, y), TILE_SOURCE_ID, atlas_coord)

func get_atlas_coord_for_element(element_type: int) -> Vector2i:
	match element_type:
		ElementTypes.EMPTY:
			return EMPTY_ATLAS_COORD
		ElementTypes.SAND:
			return SAND_ATLAS_COORD
		ElementTypes.WALL:
			return WALL_ATLAS_COORD
		ElementTypes.WATER:
			return WATER_ATLAS_COORD
		_:
			return EMPTY_ATLAS_COORD
