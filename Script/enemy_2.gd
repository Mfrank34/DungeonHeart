extends CharacterBody2D

# Movement and detection.
var playerChase = false
var player = null
var direction = "Down"  # Default direction

# Combat system.
var player_inattack_zone = false
var cooldown = true

# Knite Stats
var damage = ( 15 * Global.difficulty_level) # attack damage
var health = ( 100 * Global.difficulty_level) 
var speed = 75 # movement speed.

func _ready() -> void:
	animation_player("Down", "idle")

func _physics_process(delta: float) -> void:
	enemy(delta)
	deal_with_damage()
	attack()

# Player entering body.
func _on_detection_area_body_entered(body: Node2D) -> void: # when player enters range.
	if body.has_method("player"):
		player = body # tells the script to track the player 
		playerChase = true # gets the sctipt to start following the player.

func _on_detection_area_body_exited(body: Node2D) -> void: # player leave range.
	if body.has_method("player"):
		player = null # disables player tracking no target.
		playerChase = false # disables player chasing script.

# Combat system.
func _on_enemy_hit_box_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_inattack_zone = true

func _on_enemy_hit_box_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_inattack_zone = false

# Dealing damage to enemy.
func deal_with_damage():
	if player_inattack_zone and Global.player_current_attack:
		health -= (20 + Global.extra_damage)
		print("Knite Health: ", health)
		Global.player_current_attack = false

# Enemy dealing damage to player.
func _on_timer_timeout() -> void:
	cooldown = true

func attack():
	if player_inattack_zone and cooldown:
		var timeout = %Timer
		cooldown = false
		# change the health of player.
		Global.Player_Health -= damage
		print("Player Health: ", Global.Player_Health)
		# animation attack
		animation_player(direction, "attack")
		await get_tree().create_timer(0.5).timeout
		# starts cooldown on attack.
		timeout.start()

func add_health(gains):
	# cool maths for hp you know!
	Global.Player_Health = min(Global.Player_Health + gains, Global.Player_Max_Health)

# Enemy movement and direction handling.
func enemy(delta):
	var velocity = Vector2.ZERO
	if health <= 0:
		animation_player(direction, "death")
		await get_tree().create_timer(0.5).timeout  # Short delay before deleting
		queue_free()
		Global.amount_enemys -= 1 # removes it self from enemy amount in global.
		print("Log: Knite Dead!")
		add_health(50)
	if playerChase:
		velocity = (player.get_global_position() - position).normalized() * speed * delta
		update_direction(player.position - position)
		animation_player(direction, "walk")
	else:
		velocity = lerp(velocity, Vector2.ZERO, 0.07)
		animation_player(direction, "idle")
	move_and_collide(velocity)

func update_direction(movement: Vector2):
	# get the direction that enemy is moving in.
	if abs(movement.x) > abs(movement.y):
		direction = "Right" if movement.x > 0 else "Left"
	else:
		direction = "Down" if movement.y > 0 else "Up"

func animation_player(direction, state):
	var animation = $AnimatedSprite2D
	match direction:
		"Right":
			animation.flip_h = false
			match state:
				"attack": animation.play("attack")
				"walk": animation.play("walk")
				"death": animation.play("death")
				_: animation.play("idle")
		"Left":
			animation.flip_h = true
			match state:
				"attack": animation.play("attack")
				"walk": animation.play("walk")
				"death": animation.play("death")
				_: animation.play("idle")
		"Down":
			match state:
				"attack": animation.play("attack")
				"walk": animation.play("walk")
				"death": animation.play("death")
				_: animation.play("idle")
		"Up":
			match state:
				"attack": animation.play("attack")
				"walk": animation.play("walk")
				"death": animation.play("death")
				_: animation.play("idle")
