extends CharacterBody2D
#shout out to this man for helping me with this part https://youtu.be/pBoXqW4RykE?si=Opsn18UWjb019bTN

const speed = 100
var current_dir = "none"

func _ready() -> void:
	# sets the player default animation
	$AnimatedSprite2D.play("Front_Idle")

func _physics_process(delta):
	# allows of the player to move and so on...
	player_movement(delta)
	
func player_movement(delta):
	# play controls for the player.
	if Input.is_action_pressed("ui_right"):
		current_dir = "Right" # sets the current direction the player is facing.
		animationPlayer(current_dir, 1) # hands over the facing direction of the player and what state they are in instance moving or not.
		
		# basic movement for player within the direction they need to follow in.
		velocity.x = speed 
		velocity.y = 0
	elif Input.is_action_pressed("ui_left"):
		current_dir = "Left"
		animationPlayer(current_dir, 1)
		velocity.x = -speed
		velocity.y = 0
	elif Input.is_action_pressed("ui_down"):
		current_dir = "Down"
		animationPlayer(current_dir, 1)
		velocity.y = speed
		velocity.x = 0
	elif Input.is_action_pressed("ui_up"):
		current_dir = "Up"
		animationPlayer(current_dir, 1)
		velocity.y = -speed
		velocity.x = 0
	else:
		animationPlayer(current_dir, 0)
		velocity.x = 0
		velocity.y = 0
	
	move_and_slide();

func animationPlayer(currentDir, idle):
	var animation = $AnimatedSprite2D # allows for me to control the animated 2d in the player.
	#this part is a switch for different movement that happends within the game
	match currentDir:
		"Right":
			if idle == 1:
				animation.flip_h = false
				animation.play("Side_Walk")
			else:
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
