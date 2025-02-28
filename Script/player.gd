extends CharacterBody2D
# shout out to this man for helping me with this part
# https://youtu.be/pBoXqW4RykE?si=Opsn18UWjb019bTN
# https://youtu.be/KceMokK2qFA?si=Uzs8sBm0IIWDKleQ
# godot and unity have little learing curve womp womp

# Animation player
var current_dir = "none"

# movement values
const speed = 100
const accel = 750 # how fast to top speed
const friction = 600 # well its friction idk how else to explain...
var max_speed = 150 # top speed the player can move at 
var input = Vector2.ZERO

# Dash system
var dashSpeed = 450
var dashCoolDown = true 

# Combat System
var enemy_inattack_range = false
var enemy_attack_cooldown = true
var health = 200
var player_alive = true

	# Player Attack.
var player_attack_cooldown = true # attack in progress.

func player(): # identifier
	pass

func _ready() -> void:
	# sets the player default animation
	$AnimatedSprite2D.play("Front_Idle")

func _physics_process(delta):
	# allows of the player to move and so on...
	player_movement(delta)
	enemy_attack()
	player_attack()
	
	# when player dead delet player body.
	if health <= 0:
		player_alive = false # menu verable set....
		health = 0
		print("player has been killed.")
		self.queue_free()
	
func get_input():
	# gets the x and y inputs and normalizes the output and returns it.
	input.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	input.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	return input.normalized()

# Dash Start
func _on_timer_timeout() -> void:
	max_speed = 150
	dashCoolDown = true

func dash():
	var cooldown = $dash_cooldown
	max_speed = dashSpeed
	dashCoolDown = false  # Disable dashing
	cooldown.start()  # Start cooldown timer
# end Dash

# Combat Start
func _on_player_hit_box_body_entered(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_inattack_range = true

func _on_player_hit_box_body_exited(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_inattack_range = false

func _on_attack_cooldown_timeout() -> void:
	enemy_attack_cooldown = true

func _on_player_attack_cooldown_timeout() -> void:
	Global.player_current_attack = false
	player_attack_cooldown = true

func enemy_attack():
	var cooldown = $Enemy_attack_cooldown
	if enemy_inattack_range: # find enemy in range
		if enemy_attack_cooldown: # looks for cooldown.
			health -= 20
			print("Player Health: ", health) # debuging
			enemy_attack_cooldown = false
			cooldown.start()

func player_attack():
	var cooldown = $Player_attack_cooldown
	if Input.is_action_just_pressed("ui_accept"):
		if player_attack_cooldown:
			Global.player_current_attack = true
			player_attack_cooldown = false
			cooldown.start()

# combat end
func animationPlayer(currentDir, idle):
	var animation = $AnimatedSprite2D # allows for me to control the animated 2d in the player.
	# this part is a switch for different movement that happends within the game
	match currentDir:
		"Right":
			animation.flip_h = false # set the vaule to animation is play in direction.
			if idle == 1: # player is moving
				animation.play("Side_Walk")
			else: # player is not moving
				animation.play("Side_Idle")
		"Left":
			animation.flip_h = true
			if idle == 1:
				animation.play("Side_Walk")
			else:
				animation.play("Side_Idle")
		"Down":
			if idle == 1:
				animation.play("Front_Walk")
			else:
				animation.play("Front_Idle")
		"Up":
			if idle == 1:
				animation.play("Back_Walk")
			else:
				animation.play("Back_Idle")

func player_movement(delta):
	# play controls for the player.
	# give the player free movement within the world space and allows for them to move in each all direction with two inputs.
	input = get_input()
	if input == Vector2.ZERO:
		if velocity.length() > (friction * delta ):
			velocity -= velocity.normalized() * (friction * delta)
		else:
			velocity = Vector2.ZERO
	else:
		velocity += (input * accel * delta) # how fast the player moves in a given direction.
		velocity = velocity.limit_length(max_speed) # limits the player movement speed.
	# Dash code for dashing ik right so cool
	if Input.is_action_just_pressed("ui_dash") and dashCoolDown: # dashing and cool down system
		dash()
	# animation controls
	if Input.is_action_pressed("ui_right"):
		current_dir = "Right" # sets the current direction the player is facing.
		animationPlayer(current_dir, 1) # hands over the facing direction of the player and what state they are in instance moving or not.
	elif Input.is_action_pressed("ui_left"):
		current_dir = "Left"
		animationPlayer(current_dir, 1)
	elif Input.is_action_pressed("ui_down"):
		current_dir = "Down"
		animationPlayer(current_dir, 1)
	elif Input.is_action_pressed("ui_up"):
		current_dir = "Up"
		animationPlayer(current_dir, 1)
	else:
		animationPlayer(current_dir, 0)
	# godot function for moveable objects
	move_and_slide();
	
	
