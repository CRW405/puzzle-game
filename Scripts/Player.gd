extends CharacterBody2D



# Particle Movement
@export_group("Ground Movement")
@export var speed = 400.0   
@export var acceleration = 2000.0
@export var friction = 2000.0     

@export_group("Air Movement")
@export var jump_velocity = -600.0
@export var gravity_multiplier = 1.5
@export var air_acceleration = 1500.0 
@export var air_friction = 1000.0  

# Pixel step up
@export_group("Stair Handling")
@export var step_height = 18.0 

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Nodes
@onready var sprite = $Sprite2D
@onready var coyote_timer = $CoyoteTimer
@onready var jump_buffer_timer = $JumpBufferTimer

func _physics_process(delta):
	# Gravity
	if not is_on_floor():
		velocity.y += gravity * gravity_multiplier * delta

	# 2. Variable jump height
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= 0.5 

	# Jump logic
	if is_on_floor():
		coyote_timer.stop()
		
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer.start()
		
	if (is_on_floor() or not coyote_timer.is_stopped()) and not jump_buffer_timer.is_stopped():
		velocity.y = jump_velocity
		jump_buffer_timer.stop()
		coyote_timer.stop()

	# Movement
	var direction = Input.get_axis("move_left", "move_right")
	
	if direction:
		# Sprite lfip
		if sprite:
			sprite.flip_h = (direction < 0)

		# Acceleration
		var accel = acceleration if is_on_floor() else air_acceleration
		
		velocity.x = move_toward(velocity.x, direction * speed, accel * delta)
		
	else:
		# Stop faster on ground, slower in air
		var fric = friction if is_on_floor() else air_friction
		
		# Move toward 0 velocity
		velocity.x = move_toward(velocity.x, 0, fric * delta)

	# Move
	var was_on_floor = is_on_floor()
	move_and_slide()
	
	# Coyote Time
	if was_on_floor and not is_on_floor() and velocity.y >= 0:
		coyote_timer.start()
