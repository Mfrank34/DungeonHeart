extends Control
# Thanks to this guy for help: https://youtu.be/a0UQ-t-vuzY?si=woHZ2jEeqXjkr1nm

# ready on load
# HUD items
@onready var hud : Control = $HUD
@onready var health : Label = $HUD/Health
@onready var alive_enemys_count : Label = $HUD/EnemyLeft
@onready var buffs : Label = $HUD/Buffs
@onready var menu : Control = $Menu
# map events
@onready var main_2d : Node2D = $Main2D
@onready var enemy_2d: Node2D = $Enemy2D
@onready var player_2d: Node2D = $Player2D
# spawning
@onready var top_left : Marker2D = $Enemy2D/TopLeft
@onready var bottom_right : Marker2D = $Enemy2D/BottomRight
@onready var player_spawn : Marker2D = $Player2D/PlayerSpawn
# camera
@onready var camera : Camera2D = $Main2D/Camera

# setting for maps.
var level_instance : Node2D
var enemy_instance : Node2D
var player_instance : Node2D
# map information.
var maps = ["Level_1", "Level_2", "Level_3"] # name of maps
var enemys = ["Enemy_1", "Enemy_2", "Enemy_3"] # name of enemys
var total_map = (maps.size() - 1) # total index - 1 to put in range
var total_enemy = (enemys.size() - 1)
# limit map spawning.
var map_limits_min
var map_limits_max
var loading : bool

func _ready() -> void:
	pass

func _process(_delta) -> void:
	if loading:
		pass
	updates_display()

func unload_instance():
	unload_enemy()
	unload_level()

func unload_level():
	# Unloads the current level
	if level_instance:
		level_instance.queue_free()
		level_instance = null

func unload_enemy():
	# Unloads all enemy instances
	if enemy_2d:
		for child in enemy_2d.get_children():
			if child is Marker2D: # bug fix with unloading. 
				continue
			child.queue_free()

func button_toggle(state):
	# true to disable | fasle to enable
	for button in menu.get_children():
		if button is Button:
			button.disabled = state

func load_level(level_name : String):
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

func load_enemy(enemy_name: String):
	var enemy_path := "res://Scenes/Enemy/%s.tscn" % enemy_name
	var enemy_resource := load(enemy_path)
	if enemy_resource:
		enemy_instance = enemy_resource.instantiate()
		print("Instantiated enemy:", enemy_instance)  # Debugging
		if enemy_2d:
			enemy_2d.add_child(enemy_instance)
			# spawn coors
			var min_pos = top_left.position  # Top-left position (min)
			var max_pos = bottom_right.position  # Bottom-right position (max)
			# Generate a random position within the given range
			var random_x = randf_range(min_pos.x, max_pos.x)
			var random_y = randf_range(min_pos.y, max_pos.y)
			enemy_instance.position = Vector2(random_x, random_y)
			print("Spawned enemy at:", enemy_instance.position)
		else:
			print("Error: enemy_2d is null!")
	else:
		print("Error: Enemy not found at", enemy_path)

func load_player():
	# doesnt make second instance.
	if not player_instance:
		# create instance if not already have one.
		var player_path := "res://Scenes/Player.tscn"
		var player_resource := load(player_path)
		if player_resource:
			player_instance = player_resource.instantiate()
			if player_2d:  # Ensure player_2d is a valid node
				player_2d.add_child(player_instance)
				var spawn = player_spawn.position  # Gets location
				player_instance.position = spawn  # Spawns on marker
				print("Spawned player at:", player_instance.position)
			else:
				print("Error: player_2d is null!")
		else:
			print("Error: Player scene not found at", player_path)
	else:
		# move player back to spawn location
		player_instance.position = player_spawn.position
		print("Player repositioned to:", player_instance.position)

func level_manager() -> void:
	# unload current map and enemys if any...
	unload_instance()
	# loads new map
	var level_gen = randi_range(0, total_map) # 1 to 3 random
	load_level(maps[level_gen]) # load a random level.
	# wait for map to load.
	await get_tree().process_frame
	# load in different enemys to kill.
	var enemy_amount = randi_range(1, 6)
	Global.amount_enemys = enemy_amount
	print("Enemy amount: ", Global.amount_enemys)
	# loading multable different instance.
	for enemy in range(enemy_amount):
		var enemy_type = randi_range(0, total_enemy)
		load_enemy(enemys[enemy_type])

func updates_display() -> void:
	# Update the health label with the current player's health from Global
	health.text = "Health: %d" % Global.Player_Health
	alive_enemys_count.text = "Enemy left: %d" % Global.amount_enemys

func game_manager():
	if Global.Player_Alive:
		button_toggle(true)
		load_player()
		
		if Global.amount_enemys == 0:
			# load current level with enemy attacked.
			level_manager()
			
		if Global.Player_Health <= 0:
			# stops game loop.
			unload_instance()
			Global.Player_Alive = false
	else:
		# Player is dead, unload level ands enemies
		# Enables button
		button_toggle(false)
		# Reset values
		Global.Player_Health = Global.Player_Max_Health
		Global.amount_enemys = 0
		unload_instance()

func _on_start_pressed() -> void:
	Global.Player_Alive = true
	game_manager()

func _on_exit_pressed() -> void:
	get_tree().quit()
