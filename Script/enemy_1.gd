extends CharacterBody2D

# movement and detection.
var speed = 75
var playerChase = false
var player = null

# combat system.
var health = 100
var player_inattack_zone = false

func _physics_process(delta: float) -> void:
	enemy(delta)
	deal_with_damage()

func _on_detection_area_body_entered(body: Node2D) -> void: # when player enters range.
	player = body # tells the script to track the player 
	playerChase = true # gets the sctipt to start following the player.

func _on_detection_area_body_exited(body: Node2D) -> void: # player leave range.
	player = null # disables player tracking no target.
	playerChase = false # disables player chasing script.

# Compat system.
func _on_enemy_hit_box_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_inattack_zone = true

func _on_enemy_hit_box_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_inattack_zone = false

func deal_with_damage():
	if player_inattack_zone and Global.player_current_attack == true:
		health -= 20
		print("Slime Health: ", health)
		if health <= 0:
			self.queue_free()
# Compat end

func enemy(delta): # shows enemy.
	# michael had a problem with a word called position.
	# position += (player.position - position) / speed # gets the location of 
	# changing how enemys engage with movement system.
	var velocity = Vector2.ZERO
	
	if playerChase:
		# movement system 
		velocity = (player.get_global_position() - position).normalized() * speed * delta
		$AnimatedSprite2D.play("walk_enemy")
		if (player.position.x-position.x) < 0:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
	else:
		# Gradually slow down when not chasing
		velocity = lerp(velocity, Vector2.ZERO, 0.07)
		$AnimatedSprite2D.play("idle_enemy")
	# move charatur around.
	move_and_collide(velocity)
