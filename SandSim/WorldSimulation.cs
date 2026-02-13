using Godot;
using System;

/* New C# Simulation (Sorry c# is so much faster) - Michael
   Notes - 
   ~ It is pretty small in scope and size. We will need to implement a small
	rendering grid/chunk system in the future as it checks everything within
	the size of the simulation.
*/

public partial class WorldSimulation : Node2D
{
	// Config
	private const int Width = 256;
	private const int Height = 150;
	private const int Scale = 4;

	// Elements
	const int EL_AIR = 0;
	const int EL_SAND = 1;
	const int EL_WATER = 2;
	const int EL_STONE = 3;
	const int EL_WOOD = 4;
	const int EL_FIRE = 5;
	const int EL_SMOKE = 6;
	const int EL_STEAM = 7;
	const int EL_ASH = 8;

	struct ElementInfo
	{
		public string Name;
		public bool IsSolid;
		public bool IsLiquid;
		public bool IsGas;
		public int Density;
		public float BurningChance;
		public Color BaseColor;
	}

	private ElementInfo[] _elements;
	private int[,] _reactions;

	// data
	private int[] _grid;
	private int _particleCount = 0;
	
	// For future use
	private Image _image;
	private ImageTexture _texture;
	private Sprite2D _sprite;
	private Label _uiLabel; 
	private int _currentTool = EL_SAND;
	
	private Random _rng = new Random();

	public override void _Ready()
	{
		SetupDatabase();
		_grid = new int[Width * Height];
		
		_image = Image.Create(Width, Height, false, Image.Format.Rgba8);
		_texture = ImageTexture.CreateFromImage(_image);
		
		_sprite = new Sprite2D();
		_sprite.Texture = _texture;
		_sprite.Scale = new Vector2(Scale, Scale);
		_sprite.Centered = false;
		_sprite.TextureFilter = CanvasItem.TextureFilterEnum.Nearest;
		AddChild(_sprite);
		
		SetupUI();
	}

	// Main Process Thread
	public override void _Process(double delta)
	{
		HandleInput();
		Simulate(); 
		Render();
		UpdateUI();
	}
	
	private void SetupUI()
	{
		CanvasLayer cl = new CanvasLayer();
		AddChild(cl);
		_uiLabel = new Label();
		_uiLabel.Position = new Vector2(10, 10);
		_uiLabel.Modulate = Colors.White; 
		_uiLabel.AddThemeColorOverride("font_outline_color", Colors.Black);
		_uiLabel.AddThemeConstantOverride("outline_size", 4);
		cl.AddChild(_uiLabel);
	}

	private void UpdateUI()
	{
		string toolName = _elements[_currentTool].Name;
		_uiLabel.Text = $"FPS: {Engine.GetFramesPerSecond()}\n" +
						$"Particles: {_particleCount}\n" +
						$"Tool: {toolName} (1-5)";
	}

	private void SetupDatabase()
	{
		_elements = new ElementInfo[9];
		
		// Establishes each element data
		_elements[EL_AIR]   = new ElementInfo { Name="Air", BaseColor = Colors.Black, Density = 0 };
		_elements[EL_STONE] = new ElementInfo { Name="Stone", BaseColor = new Color("#4a4a4a"), IsSolid = true, Density = 100 };
		_elements[EL_WOOD]  = new ElementInfo { Name="Wood", BaseColor = new Color("#6d4c41"), IsSolid = true, Density = 50, BurningChance = 0.05f };
		_elements[EL_ASH]   = new ElementInfo { Name="Ash", BaseColor = new Color("#212121"), IsSolid = false, Density = 15 }; 
		_elements[EL_SAND]  = new ElementInfo { Name="Sand", BaseColor = new Color("#e6c229"), Density = 10 };
		_elements[EL_WATER] = new ElementInfo { Name="Water", BaseColor = new Color("#1ca3ec"), IsLiquid = true, Density = 5 };
		_elements[EL_FIRE]  = new ElementInfo { Name="Fire", BaseColor = new Color("#ff5722"), IsGas = true, Density = -1, BurningChance = 0.2f };
		_elements[EL_SMOKE] = new ElementInfo { Name="Smoke", BaseColor = new Color("#757575"), IsGas = true, Density = -2 };
		_elements[EL_STEAM] = new ElementInfo { Name="Steam", BaseColor = new Color("#cfd8dc"), IsGas = true, Density = -2 };
		
		// Set Interactions
		_reactions = new int[9, 9];
		for(int i=0; i<9; i++) for(int j=0; j<9; j++) _reactions[i,j] = -1;

		// FIRE LOGIC
		_reactions[EL_FIRE, EL_WOOD] = EL_FIRE; // Fire spreads to Wood
		_reactions[EL_FIRE, EL_WATER] = EL_STEAM; // Water boils
		_reactions[EL_WATER, EL_FIRE] = EL_STEAM; // Fire extinguished
		
		// Fire eventually turns Wood into Ash (handled in TryReact logic usually, but here simplifies to just spread)
	}

	private void HandleInput()
	{
		if (Input.IsKeyPressed(Key.Key1)) _currentTool = EL_SAND;
		if (Input.IsKeyPressed(Key.Key2)) _currentTool = EL_WATER;
		if (Input.IsKeyPressed(Key.Key3)) _currentTool = EL_WOOD;
		if (Input.IsKeyPressed(Key.Key4)) _currentTool = EL_FIRE;
		if (Input.IsKeyPressed(Key.Key5)) _currentTool = EL_STONE;

		if (Input.IsMouseButtonPressed(MouseButton.Left))
		{
			var mPos = GetLocalMousePosition() / Scale;
			Paint((int)mPos.X, (int)mPos.Y, _currentTool, 2);
		}
	}

	private void Simulate()
	{
		// rising elements (Fire, Smoke, Steam)
		// We iterate TOP-DOWN (y=0 to Height). 
		// This prevents them from moving up, getting processed again, and teleporting.
		for (int y = 0; y < Height; y++)
		{
			ProcessRow(y, true); // true means rising
		}

		// droping elements (Sand, Water, Ash)
		// We iterate BOTTOM-UP (y=Height to 0).
		// prevents same processing and teleporting issues
		for (int y = Height - 1; y >= 0; y--)
		{
			ProcessRow(y, false); // false means falls only
		}
	}

	private void ProcessRow(int y, bool processRising)
	{
		// RNG for more random fluid reactions
		bool leftToRight = _rng.Next(2) == 0;
		int startX = leftToRight ? 0 : Width - 1;
		int endX   = leftToRight ? Width : -1;
		int step   = leftToRight ? 1 : -1;

		for (int x = startX; x != endX; x += step)
		{
			int i = y * Width + x;
			int type = _grid[i];

			if (type == EL_AIR || _elements[type].IsSolid) continue;

			// Acts as a filter
			bool isGas = _elements[type].IsGas;
			if (processRising && !isGas) continue;
			if (!processRising && isGas) continue;

			// Checks lifetime (Fire and smoke)
			if (isGas && _rng.NextDouble() < 0.04) 
			{
				ChangePixel(i, EL_AIR);
				if (type == EL_FIRE) ChangePixel(i, EL_SMOKE);
				continue;
			}

			// Check for reactions in each direction
			if (TryReact(i, x, y, 0, 1)) continue;
			if (TryReact(i, x, y, 0, -1)) continue;
			if (TryReact(i, x, y, -1, 0)) continue;
			if (TryReact(i, x, y, 1, 0)) continue;

			// Movement Section
			int gravityDir = isGas ? -1 : 1;

			// Vert
			if (TryMove(i, x, y, 0, gravityDir, type)) continue;

			// Diag
			if (TryMove(i, x, y, -1, gravityDir, type)) continue;
			if (TryMove(i, x, y, 1, gravityDir, type)) continue;

			// HOrizontal
			if (_elements[type].IsLiquid || isGas)
			{
				 if (TryMove(i, x, y, -1, 0, type)) continue;
				 if (TryMove(i, x, y, 1, 0, type)) continue;
			}
		}
	}
	
	// Changes pixel and updates particleCount var
	// Should be noted AIR is considered 'nothing'
	private void ChangePixel(int index, int newType)
	{
		int oldType = _grid[index];
		if (oldType == EL_AIR && newType != EL_AIR) _particleCount++;
		else if (oldType != EL_AIR && newType == EL_AIR) _particleCount--;
		
		_grid[index] = newType;
	}

	private bool TryMove(int i, int x, int y, int dx, int dy, int type)
	{
		int nx = x + dx;
		int ny = y + dy;

		if (nx < 0 || nx >= Width || ny < 0 || ny >= Height) return false;

		int ni = ny * Width + nx;
		int neighbor = _grid[ni];

		bool canMove = false;
		
		// Fire burns through and moves inside wood
		if (type == EL_FIRE && neighbor == EL_WOOD) return false; 

		if (neighbor == EL_AIR) canMove = true;
		else if (_elements[type].IsGas && !_elements[neighbor].IsSolid) canMove = true; // Gas rises through liquids/sand
		else if (_elements[type].Density > _elements[neighbor].Density && !_elements[neighbor].IsSolid && !_elements[neighbor].IsGas)
		{
			canMove = true; // Sink down
		}

		if (canMove)
		{
			_grid[ni] = type;
			_grid[i] = neighbor;
			return true;
		}
		return false;
	}
	
	private bool TryReact(int i, int x, int y, int dx, int dy)
	{
		int nx = x + dx;
		int ny = y + dy;
		if (nx < 0 || nx >= Width || ny < 0 || ny >= Height) return false;

		int ni = ny * Width + nx;
		int myType = _grid[i];
		int neighbor = _grid[ni];

		if (neighbor == EL_AIR) return false;

		int result = _reactions[myType, neighbor];
		if (result != -1)
		{
			if (_elements[myType].BurningChance > 0 && _rng.NextDouble() > _elements[myType].BurningChance) return false;
			ChangePixel(ni, result); 
			if (myType == EL_FIRE && neighbor == EL_WOOD && _rng.NextDouble() < 0.1) ChangePixel(ni, EL_ASH);
			return true;
		}
		return false;
	}

	private void Paint(int cx, int cy, int type, int r)
	{
		for (int y = -r; y <= r; y++) for (int x = -r; x <= r; x++)
		{
			 if (x*x + y*y <= r*r)
			 {
				 int px = cx + x, py = cy + y;
				 if (px >= 0 && px < Width && py >= 0 && py < Height)
					 if (_grid[py * Width + px] != EL_STONE)
						ChangePixel(py * Width + px, type);
			 }
		}
	}

	// Render 
	private void Render()
	{
		for (int i = 0; i < _grid.Length; i++)
		{
			int type = _grid[i];
			if (type == EL_AIR) 
			{
				_image.SetPixel(i % Width, i / Width, Colors.Black);
				continue;
			}

			// Calculate deterministic noise based on position
			// This makes the texture stick to the particle, or shimmer if it moves
			int x = i % Width;
			int y = i / Width;
			
			// A simple pseudo-random hash function for dithering
			float noise = ((x * 2341 + y * 4231) % 100) / 100.0f;
			
			Color baseColor = _elements[type].BaseColor;
			Color finalColor = baseColor;

			// apply texture
			if (type == EL_STONE)
			{
				// Stone- darker noise
				finalColor = baseColor.Darkened(noise * 0.2f);
			}
			else if (type == EL_SAND || type == EL_WOOD || type == EL_ASH)
			{
				// Wood- slight grain
				finalColor = baseColor.Lightened((noise - 0.5f) * 0.1f);
			}
			else if (type == EL_WATER)
			{
				// Water- Sways
				finalColor = baseColor.Lightened(noise * 0.1f);
			}
			else if (type == EL_FIRE)
			{
				// Fire- Flickers like real fire
				float flicker = (float)_rng.NextDouble();
				if (flicker > 0.6) finalColor = Colors.Yellow;
				else if (flicker > 0.3) finalColor = Colors.Orange;
				else finalColor = Colors.Red;
			}
			else if (type == EL_SMOKE || type == EL_STEAM)
			{
				// Smoke- fades
				finalColor = baseColor.Darkened((float)_rng.NextDouble() * 0.1f);
			}

			_image.SetPixel(x, y, finalColor);
		}
		_texture.Update(_image);
	}
}
