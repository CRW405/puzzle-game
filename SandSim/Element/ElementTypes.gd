## ElementTypes - Element Type Registry
##
## Defines all element types in the simulation as integer constants.
## Using integers instead of objects makes the simulation extremely fast:
## - No object allocation overhead
## - Cache-friendly memory layout
## - Simple array storage
##
## This class also provides utility functions for getting element colors and names.

extends RefCounted
class_name ElementTypes

# Element type constants
# Each element is just an integer for maximum performance
# The grid stores these integers directly
enum {
	EMPTY,   # Air/void - particles fall through this
	SAND,    # Falls and piles up
	WALL,    # Static barrier
	WATER    # Liquid - flows and spreads
}

## Returns the display color for an element type
## Used by UI and debugging - the actual rendering uses a texture atlas
static func get_color(element_type: int) -> Color:
	match element_type:
		EMPTY:
			return Color.BLACK
		SAND:
			return Color.YELLOW
		WALL:
			return Color.GRAY
		WATER:
			return Color.BLUE
		_:  # Default for unknown types
			return Color.BLACK

## Returns the display name for an element type
## Used by the UI to show which element is currently selected
static func get_element_name(element_type: int) -> String:
	match element_type:
		EMPTY:
			return "Empty"
		SAND:
			return "Sand"
		WALL:
			return "Wall"
		WATER:
			return "Water"
		_:  # Default for unknown types
			return "Unknown"

