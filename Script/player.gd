extends CharacterBody2D
# shout out to this man for helping me with this part
# https://youtu.be/pBoXqW4RykE?si=Opsn18UWjb019bTN
# https://youtu.be/KceMokK2qFA?si=Uzs8sBm0IIWDKleQ
# godot and unity have little learing curve womp womp

const speed = 100
var current_dir = "none"

# movement values
var max_speed = 150 # top speed the player can move at 
const accel = 750 # how fast to top speed
const friction = 600 # well its friction idk how else to explain...
var input = Vector2.ZERO
var dashSpeed = 450
var dashCoolDown = true # start with a dash

func _ready() -> void:
	# sets the player default animation
	$AnimatedSprite2D.play("Front_Idle")

func _physics_process(delta):
	# allows of the player to move and so on...
	player_movement(delta)
	
func get_input():
	# gets the x and y inputs and normalizes the output and returns it.
	input.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	input.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	return input.normalized()
	
func dash():
	var cooldown = $Timer
	max_speed = dashSpeed
	dashCoolDown = false  # Disable dashing
	cooldown.start()  # Start cooldown timer

func _on_timer_timeout() -> void:
	max_speed = 150
	dashCoolDown = true
	
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
