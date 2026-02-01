# Sand Simulator

A falling sand physics simulator built with Godot 4.6.

## Controls

- **Number Keys 1-3**: Select element to place
  - 1 = Wall (gray, static barrier)
  - 2 = Sand (yellow, falls and settles)
  - 3 = Water (blue, flows and spreads)
- **Left Click**: Place selected element
- **Right Click**: Erase elements

## How It Works

### Core Architecture

**WorldTileMap.gd** - Main game controller

- Sets up the simulation grid (128x128 cells)
- Runs the physics update loop every frame
- Creates and manages UI labels showing FPS, cell count, and current element
- Coordinates between simulation, rendering, and input systems

**Simulation.gd** - Physics engine

- Stores the grid as a 2D array of element types
- Updates physics each step using a checkerboard scanning pattern to prevent directional bias
- The scan direction alternates each frame so particles don't always favor one side
- Only processes active elements (sand and water) to save performance

**TileMapRenderer.gd** - Visual display

- Creates a tilemap texture atlas with colored squares for each element
- Converts the simulation grid into visual tiles
- Updates the display every frame to show particle movement

**InputHandler.gd** - User input

- Tracks which element is currently selected
- Handles number key presses to switch elements
- Converts mouse position to grid coordinates
- Places elements in a circular brush pattern around the cursor

### Element System

The simulation uses an object-oriented hierarchy where each element type has specific behaviors.

**ElementTypes.gd** - Element registry

- Defines constants for each element type (EMPTY, SAND, WALL, WATER)
- Factory function creates element objects from type IDs
- Provides color and name lookups for rendering and UI

**Element.gd** - Base class

- Abstract parent class for all elements
- Defines the step function that subclasses override for movement
- Includes displacement logic to determine what elements can move into

**Solid.gd** - Solid materials

- Base class for all solid elements
- Can move into empty spaces
- Provides foundation for movable and immovable variants

**MovableSolid.gd** - Falling particles (sand)

- Gravity-based movement: tries to fall down first
- If blocked, attempts diagonal movement (down-left or down-right)
- Can sink through liquids by swapping positions
- Direction is randomized each step for natural spreading

**ImmovableSolid.gd** - Static barriers (wall)

- Never moves once placed
- Cannot be displaced by other elements
- Used to create containers and obstacles

**Liquid.gd** - Flowing fluids

- Falls due to gravity like solids
- Spreads horizontally when blocked from falling
- Has a dispersion rate controlling how far it spreads each step
- Creates realistic pooling and flowing behavior

**Water.gd** - Water implementation

- Extends Liquid with blue color
- Dispersion rate of 5 tiles per step
- Rises above sinking sand particles

### Physics Details

**Gravity and Movement**
All movable elements (sand and water) attempt to move down first. If blocked, they try diagonal movements.
This creates piling and settling.

**Liquid Displacement**
When sand falls into water, they swap positions. Sand moves down while water moves up,
creating sinking behavior and water displacement.

**Checkerboard Scanning**
The simulation processes cells in alternating patterns to prevent artifacts.
Without this, elements would consistently favor one direction. The pattern changes each frame for balanced physics.

**Horizontal Spreading**
Liquids check multiple cells horizontally when blocked from falling.
They move to the furthest empty space within their dispersion rate, creating fast spreading.

## Technical Specifications

- Grid: 128 x 128 cells
- Tile size: 5 x 5 pixels
- Brush radius: 3 cells
- Update rate: 60 FPS
- Rendering: TileMapLayer with procedural atlas

## File Structure

```
SandSim/
├── WorldTileMap.gd          # Main game loop
├── Simulation.gd            # Physics engine
├── TileMapRenderer.gd       # Visual rendering
├── InputHandler.gd          # User input
└── Element/
    ├── ElementTypes.gd      # Element registry
    ├── Abstract/
    │   ├── Element.gd       # Base element
    │   ├── Solid.gd         # Solid base
    │   ├── MovableSolid.gd  # Falling solid
    │   ├── ImmovableSolid.gd # Static solid
    │   └── Liquid.gd        # Fluid base
    ├── Solids/
    │   ├── Empty.gd         # Air/void
    │   ├── Sand.gd          # Sand particle
    │   └── Wall.gd          # Barrier
    └── Liquids/
        └── Water.gd         # Water fluid
```

## Adding New Elements

To add a new element type:

1. Create a new class file extending the appropriate base class
2. Add the element constant to ElementTypes enum
3. Update the create, get_color, and get_element_name functions
4. Add to the simulation step function if it moves
5. Update TileMapRenderer atlas if using tilemap rendering
6. Add input binding in InputHandler if needed

The modular design makes expansion straightforward while keeping existing elements unchanged.

## Current problems

1. Slow, once you reach a few thousand cells, fps halves

- solution may be to break up processing into chunks and utilize multithreading

2. There's this weird row effect on the edges of water and as elements fall

- Don't know why but its a relatively minor problem

3. I really don't like the element creation flow, I would prefer a define and forget flow but as of now,
   it must also be configured in ElementTypes.gd.
4. Haven't Added a player yet but it should be relatively simple due to the use of tilemaplayer
5. I'm not exactly sure how added assets for the foreground will go, eg non simulated platforms and props

This is really just a basic proof of concept for the element system,there is still a lot to
work on going forward but hopefully this serves as a good launching off point
