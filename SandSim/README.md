# SandSim - Falling Sand Simulation

A cellular automaton-based falling sand simulation built in Godot 4 using GDScript.

## Architecture Overview

The simulation is split into four main components:

```
World.gd          - Main controller: initialization, game loop, UI
Simulation.gd     - Physics engine: matrix storage, cell updates, dirty tracking
Renderer.gd       - Display: TileMapLayer rendering with atlas textures
InputHandler.gd   - User interaction: element placement/removal with brush
```

## How It Works

### Grid System
- The world is a 2D matrix (`matrix[y][x]`) where each cell holds an element ID
- Default size: 320x180 cells with 2px tile size
- Elements are integers defined in `Registry.elements` enum: `EMPTY`, `WALL`, `SAND`, `WATER`

### Simulation Loop (`Simulation.stepAll()`)
Each frame, the simulation processes all moving elements:

1. **Bottom-to-top processing** - Cells are updated from bottom to top so gravity works correctly (lower cells move first)

2. **Checkerboard alternation** - Start position alternates each frame:
   - Even frames: process left-to-right on even rows, right-to-left on odd rows
   - This prevents visual "stilting" and creates more natural-looking physics

3. **Element behaviors** - Each moving element type has its own behavior class (e.g., `Sand.step()`)

### Sand Behavior (`Elements/Solids/Sand.gd`)
Sand follows these rules in priority order:
1. **Fall straight down** if cell below is empty
2. **Pile diagonally** - randomly try left or right diagonal, then try the other direction
3. **Stay in place** if no valid moves

### Dirty Cell Rendering
Only cells that changed are re-rendered each frame:
- `Simulation.dirty_cells` tracks modified positions
- `Util.dirty_cells` collects changes from element behaviors
- `Renderer.update_dirty()` only updates changed tiles

### Registry System (`Elements/Registry.gd`)
Central lookup for element properties:
- `get_color(type)` - Returns element color for rendering
- `get_element_name(type)` - Returns display name
- `get_behaviour(type, ...)` - Dispatches to element-specific physics

Groups simplify logic:
- `UNMOVING`: `[EMPTY, WALL]` - skipped during physics
- `MOVING`: `[SAND, WATER]` - processed each step

## Controls

| Input | Action |
|-------|--------|
| Left Click | Place current element |
| Right Click | Erase (place EMPTY) |
| 1 | Select Wall |
| 2 | Select Sand |
| 3 | Select Water |

## Adding New Elements

1. Add to `Registry.elements` enum
2. Add color in `Registry.get_color()`
3. Add name in `Registry.get_element_name()`
4. Create behavior class in `Elements/` (e.g., `Elements/Liquids/Water.gd`)
5. Register behavior in `Registry.get_behaviour()`
6. Add to `MOVING` or `UNMOVING` array
7. Add atlas coord in `Renderer.gd` and update `get_atlas_coord()`
8. Add key binding in `InputHandler.gd`

## Configuration

Adjustable via `@export` variables in `World.gd`:
- `matrix_width` / `matrix_height` - Grid dimensions
- `tile_size` - Pixel size of each cell
- `brush_size` - Placement brush radius
- `sim_speed` - Physics steps per frame
