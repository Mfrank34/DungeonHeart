extends Control
# Thanks to this guy for help: https://youtu.be/a0UQ-t-vuzY?si=woHZ2jEeqXjkr1nm

# ready on load
@onready var hud : Control = $HUD
@onready var menu : Control = $Menu
@onready var main_2d : Node2D = $Main2D
@onready var camera : Camera2D = $Main2D/Camera

# setting for maps
var level_instance : Node2D
var maps = ["Level_1", "Level_2", "Level_3"]
var enemys = ["Enemy_1", "Enemy_2", "Enemy_3"]
var map_limits_min = Vector2 (25, 15) # Top-left corner
var map_limits_max = Vector2 (24 , 15) # Bottom-right corner

func _ready() -> void:
	pass

func unload_level():
	# Unloads the current level
	if level_instance:
		level_instance.queue_free()
		level_instance = null

func load_level(level_name : String):
	unload_level()
	# gets the path to load and remove the ending so just name to get with string
	var level_path := "res://Scenes/Room/%s.tscn" % level_name
	var level_resource := load(level_path)
	# error checking map loading
	if level_resource:
		level_instance = level_resource.instantiate()
		main_2d.add_child(level_instance)
		# Reset level position
		level_instance.position = Vector2.ZERO
		print("Loaded level at:", level_instance.position)
	else:
		print("Error: Level not found at", level_path)  # Debugging

func load_enemy(enemy_name: String, min_pos: Vector2, max_pos: Vector2):
	var enemy_path := "res://Scenes/Enemy/%s.tscn" % enemy_name
	var enemy_resource := load(enemy_path)
	if enemy_resource:
		var enemy_instance = enemy_resource.instantiate()
		main_2d.add_child(enemy_instance)
		# Generate a random position within the given range
		var random_x = randf_range(min_pos.x, max_pos.x)
		var random_y = randf_range(min_pos.y, max_pos.y)
		enemy_instance.position = Vector2(random_x, random_y)
		print("Spawned enemy at:", enemy_instance.position)
	else:
		print("Error: Enemy not found at", enemy_path)  # Debugging

func _on_start_pressed() -> void:
	load_level("Level_1")
	load_enemy("Enemy_1", map_limits_min, map_limits_max)


func _on_exit_pressed() -> void:
	unload_level()
