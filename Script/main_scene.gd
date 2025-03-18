extends Control
# Thanks to this guy for help: https://youtu.be/a0UQ-t-vuzY?si=woHZ2jEeqXjkr1nm

# ready on load
@onready var hud : Control = $HUD
@onready var menu : Control = $Menu
@onready var main_2d : Node2D = $Main2D
@onready var enemy_2d: Node2D = $Enemy2D
@onready var camera : Camera2D = $Main2D/Camera

# setting for maps
var level_instance : Node2D
var enemy_instance : Node2D
var maps = ["Level_1", "Level_2", "Level_3"]
var enemys = ["Enemy_1", "Enemy_2", "Enemy_3"]
var total_map = 2 # 0 to 2
var total_enemy = 2 # 0 to 2 
var map_limits_min = Vector2 (1,4) # Top-left corner
var map_limits_max = Vector2 (45, 25) # Bottom-right corner

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
		print("Instantiated enemy:", enemy_instance)  # Debugging
		if enemy_2d:
			enemy_2d.add_child(enemy_instance)
			# Generate a random position within the given range
			var random_x = randf_range(min_pos.x, max_pos.x)
			var random_y = randf_range(min_pos.y, max_pos.y)
			enemy_instance.position = Vector2(random_x, random_y)
			print("Spawned enemy at:", enemy_instance.position)
		else:
			print("Error: enemy_2d is null!")
	else:
		print("Error: Enemy not found at", enemy_path)

func level_manager() -> void:
	var level_gen = randi_range(0, total_map) # 1 to 3 random
	load_level(maps[level_gen]) # load a random level.
	# load in different enemys to kill.
	var enemy_amount = randi_range(1, 6)
	Global.amount_enemys = enemy_amount
	print("Enemy amount: ", Global.amount_enemys)
	for enemy in range(enemy_amount):
		var enemy_type = randi_range(0, total_enemy)
		load_enemy(enemys[enemy_type], map_limits_min, map_limits_max)

func _on_start_pressed() -> void:
	level_manager()


func _on_exit_pressed() -> void:
	unload_level()
