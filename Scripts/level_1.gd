extends Node2D

# Ref
@onready var player = $Entities/Player

# Settings
@export var death_height: float = 800.0

func _process(delta):
	if player.global_position.y > death_height:
		print("Player fell! Restarting...")
		restart_level()

	# Manual restart
	if Input.is_action_just_pressed("ui_cancel"): 
		restart_level()

func restart_level():
	# Reloads scene
	get_tree().reload_current_scene()
