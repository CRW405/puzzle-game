# Godot Project Structure 
---

```text
res://
├── Main.tscn (The absolute root of the game)
│
├── Autoloads/ (Global Singletons - Always Active)
│   ├── GameManager.gd       (Handles level loading/restarting/death)
│   ├── PlayerInventory.gd   (Tracks Nuts collected and current Orb ammo)
│   └── ECS_World.gd         (The invisible simulation grid and arrays)
│
└── Levels/
    └── Level_01.tscn (Loaded dynamically by GameManager)
        ├── LevelUI (CanvasLayer)
        │   └── OrbCounters (HBoxContainer -> Labels)
        │
        ├── Environment (Node2D)
        │   ├── Terrain (TileMapLayer - Solid ground/walls)
        │   └── Hazards (Node2D - Spikes, crushers)
        │
        ├── ECS_Visuals (Node2D)
        │   ├── ElementRenderer (MultiMeshInstance2D - Draws the grid blocks)
        │   └── ParticleRenderer (MultiMeshInstance2D - Draws the sparks/splashes)
        │
        ├── Player (CharacterBody2D)
        │   ├── Sprite & AnimationPlayer
        │   ├── CollisionShape2D
        │   └── CastPoint (Marker2D - Where spells spawn from)
        │
        └── Interactables (Node2D)
            ├── Nuts (Area2D - Win condition)
            └── Orbs (Area2D - Elemental ammo)
```
``` mermaid
sequenceDiagram
    participant P as Player (Godot)
    participant I as Inventory (Autoload)
    participant E as ECS_World (Autoload)
    participant V as ECS_Visuals (Godot)

    Note over P,V: Example: Casting an Earth Block
    P->>I: Cast 'Earth' pressed
    I-->>P: Check: Earth Orbs > 0? (Yes)
    I->>I: Deduct 1 Earth Orb
    P->>E: Request Earth Block at Mouse/Grid [X,Y]
    E->>E: Validate Grid is empty
    E->>E: Register new Earth Entity in 1D Array
    E->>V: Push updated grid data to Renderers
    E->>P: Spawn invisible StaticBody2D at [X,Y] so Player can stand on it
