## TileMapRenderer - Visual Display System
##
## This class handles all rendering of the simulation grid.
## It converts the abstract grid of element types into visible tiles on screen.
##
## Key Optimizations:
## - Procedural texture atlas (created at runtime, no external assets needed)
## - Dirty rectangle rendering (only redraws changed cells, 5-50x faster)
## - First render draws everything, subsequent renders only update dirty cells
##
## How it works:
## 1. Creates a texture atlas with colored squares for each element type
## 2. Maps element types to atlas coordinates
## 3. Updates only the cells that changed since last frame

extends Node
class_name TileMapRenderer

# The Godot TileMapLayer node that displays the grid
var tile_map: TileMapLayer

# Grid dimensions (must match simulation)
var grid_width: int
var grid_height: int

# Size of each tile in pixels
var tile_size: int

# Track if this is the first render (need to draw everything)
var first_render: bool = true

# TileSet constants - these reference positions in the texture atlas
const TILE_SOURCE_ID = 0              # ID of our tileset source
const EMPTY_ATLAS_COORD = Vector2i(0, 0)  # Empty cell position in atlas
const SAND_ATLAS_COORD = Vector2i(1, 0)   # Sand position in atlas
const WALL_ATLAS_COORD = Vector2i(2, 0)   # Wall position in atlas
const WATER_ATLAS_COORD = Vector2i(3, 0)  # Water position in atlas

## Initializes the renderer
## Creates the TileMapLayer node and sets up the tileset
func initialize(width: int, height: int, tile_sz: int, parent: Node):
	grid_width = width
	grid_height = height
	tile_size = tile_sz
	
	# Create the tilemap node
	tile_map = TileMapLayer.new()
	# Assign our procedurally generated tileset
	tile_map.tile_set = create_tile_set()
	# Add to scene tree so it's visible
	parent.add_child(tile_map)

## Creates the TileSet with our texture atlas
## This is done procedurally at runtime - no external sprite files needed
func create_tile_set() -> TileSet:
	var tile_set = TileSet.new()
	# Set the size of each tile
	tile_set.tile_size = Vector2i(tile_size, tile_size)
	
	# Create an atlas source (a texture with multiple tiles in it)
	var source = TileSetAtlasSource.new()
	source.texture = create_texture_atlas()  # Our procedural texture
	source.texture_region_size = Vector2i(tile_size, tile_size)
	
	# Register each tile position in the atlas
	# Each create_tile() call defines one usable tile
	source.create_tile(EMPTY_ATLAS_COORD)  # Black square for empty
	source.create_tile(SAND_ATLAS_COORD)   # Yellow square for sand
	source.create_tile(WALL_ATLAS_COORD)   # Gray square for wall
	source.create_tile(WATER_ATLAS_COORD)  # Blue square for water
	
	# Add the atlas to the tileset
	tile_set.add_source(source, TILE_SOURCE_ID)
	
	return tile_set

## Creates a procedural texture atlas with colored squares
## This is a 4x1 grid of tiles: [Empty][Sand][Wall][Water]
## Each tile is just a solid colored square
func create_texture_atlas() -> ImageTexture:
	# Create a 4-tile-wide, 1-tile-tall image
	var atlas_width = tile_size * 4
	var atlas_height = tile_size
	var image = Image.create(atlas_width, atlas_height, false, Image.FORMAT_RGBA8)
	
	# Fill each tile with a solid color
	# Tile 0: EMPTY (black)
	image.fill_rect(Rect2i(0, 0, tile_size, tile_size), Color.BLACK)
	
	# Tile 1: SAND (yellow)
	image.fill_rect(Rect2i(tile_size, 0, tile_size, tile_size), Color.YELLOW)
	
	# Tile 2: WALL (gray)
	image.fill_rect(Rect2i(tile_size * 2, 0, tile_size, tile_size), Color.GRAY)
	
	# Tile 3: WATER (dodger blue)
	image.fill_rect(Rect2i(tile_size * 3, 0, tile_size, tile_size), Color.DODGER_BLUE)
	
	# Convert Image to ImageTexture so it can be used by the TileSet
	return ImageTexture.create_from_image(image)

## Updates the visual display based on the simulation grid
## On first call, renders everything. On subsequent calls, only renders dirty cells.
## This dirty rectangle optimization is critical for performance with large grids.
func update(grid: Array, dirty_cells: Dictionary = {}):
	# First render: draw the entire grid
	if first_render:
		for y in range(grid_height):
			for x in range(grid_width):
				# Look up what element is at this position
				var atlas_coord = get_atlas_coord_for_element(grid[y][x])
				# Set the tile at this grid position
				tile_map.set_cell(Vector2i(x, y), TILE_SOURCE_ID, atlas_coord)
		first_render = false
	else:
		# Subsequent renders: only update cells that changed
		# This is 5-50x faster depending on how many cells changed
		for pos in dirty_cells.keys():
			var atlas_coord = get_atlas_coord_for_element(grid[pos.y][pos.x])
			tile_map.set_cell(pos, TILE_SOURCE_ID, atlas_coord)

## Maps an element type to its atlas coordinate
## This determines which colored square to use for rendering
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
		_:  # Default fallback for unknown types
			return EMPTY_ATLAS_COORD
