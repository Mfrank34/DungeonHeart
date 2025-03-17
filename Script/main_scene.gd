extends Control
# Thanks to this guy for help: https://youtu.be/a0UQ-t-vuzY?si=woHZ2jEeqXjkr1nm

@onready var hud : Control = $HUD
@onready var menu : Control = $Menu
@onready var main_2d : Node2D = $Main2D
@onready var camera : Camera2D = $Main2D/Camera
var level_instance : Node2D

func _ready() -> void:
	pass

func unload_level():
	# Unloads the current level
	if level_instance:
		level_instance.queue_free()
		level_instance = null

func load_level(level_name : String):
	unload_level()
	var level_path := "res://Scenes/room/%s.tscn" % level_name
	var level_resource := load(level_path)
	
	if level_resource:
		level_instance = level_resource.instantiate()
		main_2d.add_child(level_instance)
		# Reset level position
		level_instance.position = Vector2.ZERO
		print("Loaded level at:", level_instance.position)
	else:
		print("Error: Level not found at", level_path)  # Debugging

func _on_start_pressed() -> void:
	load_level("Level_1")

func _on_exit_pressed() -> void:
	unload_level()
