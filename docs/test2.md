# Elemental Puzzle Platformer: Prototype Roadmap

## Project Goal
Build a fully playable vertical slice demonstrating Player Movement, Earth/Water interactions, and the Orb/Nut economy.

---

## Phase 1: Core Systems and Infrastructure
**Objective:** Establish the foundation for physics, the custom ECS grid logic, and basic level structure.

### Front-End / Physics Programmer Tasks
**Focus:** Player agency and environmental collisions.

* **The Fairy Controller:** Build the CharacterBody2D for the Fairy. Implement platformer physics including gravity, variable jump height, and coyote time.
* **The Casting Prototype:** Create a basic projectile (AnimatableBody2D) that shoots toward the mouse cursor when the player clicks. It must terminate upon collision with a wall.
* **Hazard Hitboxes:** Create a basic Area2D Spike that detects the Fairy and triggers a die() function for testing.

### Back-End / ECS Programmer Tasks
**Focus:** Data architecture and coordinate translation.

* **The Autoload:** Setup ECS_World.gd as a global singleton.
* **Grid Conversion Math:** Write the functions to convert 2D world coordinates into a 1D Array index based on a fixed grid size (e.g., 16x16 pixels). The logic follows the standard formula:
  $$index = x + (y \cdot \text{gridWidth})$$
* **The Proxy Spawner:** Write a function so that when the Front-End signals a cast at a specific index, the ECS spawns a physical StaticBody2D at that coordinate to provide collision.

### Level Designer and UI Tasks
**Focus:** Environment scaffolding and debug visualization.

* **Level Template:** Create the base Level_01.tscn. Set up the Godot TileMapLayer with placeholder solid blocks for the floor and walls.
* **The Economy Nodes:** Create simple Area2D nodes for Orb and Nut collectibles. On contact, they should queue_free() and update the inventory state.
* **Debug HUD:** Create a CanvasLayer with a simple Label that displays the current X/Y grid coordinate of the mouse cursor to assist with back-end debugging.

---

## Phase 2: The Elements (Reactions and Rendering)
**Objective:** Make the grid dynamic. Introduce Water and implement its reaction with Earth to create a climbable Vine.

### Front-End / Physics Programmer Tasks
* **Climbable Vines:** Create a Proxy_Vine.tscn (Area2D). When the Fairy is inside this area, disable gravity and enable vertical movement.
* **Inventory Bridge:** Connect the Fairy's casting ability to an inventory script. Prevent casting if the player has 0 Orbs.
* **Death and Respawn:** Implement the logic where hitting a hazard reloads the current scene and resets the player's position.

### Back-End / ECS Programmer Tasks
* **The Interaction Matrix:** Build InteractionRules.gd. Implement the logic: If Earth is adjacent to Water, delete both elements and spawn a Vine element.
* **Grid Gravity:** Implement a system in the ECS that makes fluid elements (like Water) fall down the grid array one cell at a time if the cell below them is empty.
* **Flyweight Particle Rendering:** Setup the MultiMeshInstance2D script that reads the ECS arrays and draws all active elements in a single batch for performance.

### Level Designer and UI Tasks
* **Inventory UI:** Build the screen UI showing current counts for Water Orbs, Earth Orbs, and Nuts collected.
* **Puzzle Sandbox:** Design a test level that requires the player to collect a Water Orb, climb a ledge, cast an Earth block, and cast Water on it to create a Vine to reach the Nut.
* **Visual Polish:** Replace placeholder sprites with final pixel art for the Fairy, Elements, and Tiles.

---

## Phase 3: The Game Loop (Progression and Polish)
**Objective:** Connect the systems into a full game loop from the Main Menu to the Level Complete screen.

### Front-End / Physics Programmer Tasks
* **Level Transitions:** Build the logic in GameManager.gd to unload Level 1 and load Level 2 when the Nut is collected.
* **Camera Work:** Implement a Camera2D that smoothly follows the Fairy and clamps to the edges of the TileMap.

### Back-End / ECS Programmer Tasks
* **Persistent State:** Ensure that when a player dies and the level resets, the Orbs they spent are refunded, but any Nuts they permanently secured in previous levels are saved.
* **ECS Optimization:** Profile the physics process loop. Ensure the grid updates are not causing frame drops during heavy reactions.

### Level Designer and UI Tasks
* **Menus:** Create the Main Menu, Pause Menu, and Level Complete screens.
* **Audio Implementation:** Add Godot AudioStreamPlayer nodes for casting sounds, collecting Orbs, and background music.
