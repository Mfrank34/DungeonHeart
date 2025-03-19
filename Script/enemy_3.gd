extends CharacterBody2D

@onready var animation = $AnimatedSprite2D
# Movement and detection.
var playerChase = false
var player = null
var direction = "Down"  # Default direction

# Combat system.
var player_inattack_zone = false
var cooldown = true

# Golbin Stats
var damage = 15 # attack damage
var health = 125 # slimes health 
var speed = 125 # movement speed.

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
		health -= 30
		print("Golbin Health: ", health)
		Global.player_current_attack = false

func _on_timer_timeout() -> void:
	#print("Golbin Debug | timer off")
	cooldown = true

func attack():
	# detection you know, so sick of this not working!
	if player_inattack_zone and cooldown:
		var timeout = %Timer
		cooldown = false
		#rint("Golbin Debug | timer on")
		# dealin with player damage
		Global.Player_Health -= damage
		print("Player Health: ", Global.Player_Health)
		# animation attack
		animation_player(direction, "attack")
		# starting timer.
		timeout.start()

# Enemy movement and direction handling.
func enemy(delta):
	var velocity = Vector2.ZERO
	if health <= 0:
		Global.amount_enemys -= 1 # removes it self from enemy amount in global.
		animation_player(direction, "death")
		await get_tree().create_timer(0.5).timeout  # Short delay before deleting
		queue_free()
		return
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
