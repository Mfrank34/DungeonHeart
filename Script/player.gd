extends CharacterBody2D
# shout out to this man for helping me with this part
# https://youtu.be/pBoXqW4RykE?si=Opsn18UWjb019bTN
# https://youtu.be/KceMokK2qFA?si=Uzs8sBm0IIWDKleQ
# godot and unity have little learing curve womp womp

# Animation player
var direction = "none"
var status = "none"
# movement values
var input = Vector2.ZERO # vector information from awsd.
# movement feel.
const speed = 100
const accel = 750 # how fast to top speed
const friction = 600 # well its friction idk how else to explain...
# max speed.
var max_speed = (125 + Global.extra_movement) # top speed the player can move at 
# Dash system
var dashSpeed = (450 + Global.extra_movement)
var dashCoolDown = true 
# Combat System
var player_attack_cooldown = true
var enemy_inattack_range = false
# end of combat system. 

func player(): # identifier
	pass

func _ready() -> void:
	# sets the player default animation
	$AnimatedSprite2D.play("Down_Idle")

func _physics_process(delta):
	# allows of the player to move and so on...
	player_movement(delta)

func get_input():
	# gets the x and y inputs and normalizes the output and returns it.
	input.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	input.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	return input.normalized()

# Dash Start
func _on_timer_timeout() -> void:
	max_speed = (125 + Global.extra_movement)
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

func _on_player_attack_cooldown_timeout() -> void:
	Global.player_current_attack = false
	player_attack_cooldown = true

func player_attack():
	var cooldown = $Player_Attack_Cooldown
	if player_attack_cooldown:
		Global.player_current_attack = true
		player_attack_cooldown = false
		cooldown.start()

# combat end
@warning_ignore("shadowed_variable")
func animation_player(direction, state):
	var animation = $AnimatedSprite2D 
	# allows for me to control the animated 2d in the player.
	# this part is a switch for different movement that happends within the game
	match direction:
		"Right":
			animation.flip_h = false # set the vaule to animation is play in direction.
			match state:
				"attack":
					animation.play("Side_Attack")
				"dash":
					pass
				"walk":
					animation.play("Side_Walk")
				_:
					animation.play("Side_Idle")
		"Left":
			animation.flip_h = true
			match state:
				"attack":
					animation.play("Side_Attack")
				"dash":
					animation.play("Side_Dash")
				"walk": 
					animation.play("Side_Walk")
				_:
					animation.play("Side_Idle")
		"Down":
			match state:
				"attack":
					animation.play("Down_Attack")
				"dash":
					animation.play("Down_Dash")
				"walk":
					animation.play("Down_Walk")
				_:
					animation.play("Down_Idle")
		"Up":
			match state:
				"attack":
					animation.play("Up_Attack")
				"dash":
					animation.play("Up_Dash")
				"walk":
					animation.play("Up_Walk")
				_:
					animation.play("Up_Idle")
		_: pass

func player_movement(delta):
	# death animation.
	if Global.Player_Health <= 0:
		Global.Player_Alive = false
		animation_player(direction, "death")
		await get_tree().create_timer(0.5).timeout  # Short delay before deleting
		queue_free()
		return
	# animation controls
	if input != Vector2.ZERO:
		match input:
			Vector2.RIGHT:
				direction ="Right"
			Vector2.LEFT:
				direction = "Left"
			Vector2.DOWN:
				direction = "Down"
			Vector2.UP:
				direction = "Up"
	# play controls for the player.
	# give the player free movement within the world space and allows for them to move in each all direction with two inputs.
	input = get_input()
	if input == Vector2.ZERO:
		if velocity.length() > (friction * delta ):
			velocity -= velocity.normalized() * (friction * delta)
		else:
			velocity = Vector2.ZERO
			# animation reset.
			if player_attack_cooldown:
				status = "none" # idle animation set
	else:
		velocity += (input * accel * delta) # how fast the player moves in a given direction.
		velocity = velocity.limit_length(max_speed) # limits the player movement speed.
		if player_attack_cooldown:
			status = "walk" # walk animation set.
	
	# Dash code for dashing ik right so cool
	if Input.is_action_just_pressed("ui_dash") and dashCoolDown: # dashing and cool down system
		status = "dash" # setting dash animation.
		dash()

	if Input.is_action_just_pressed("ui_accept"):
		status = "attack" # sets the attack animation.
		player_attack()
	# animation
	animation_player(direction, status)
	# godot function for moveable objects
	move_and_slide()
