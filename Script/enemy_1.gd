extends CharacterBody2D

var speed = 150
var playerChase = false
var player = null

func _on_detection_area_body_entered(body: Node2D) -> void: # when player enters range.
	player = body # tells the script to track the player 
	playerChase = true # gets the sctipt to start following the player.

func _on_detection_area_body_exited(body: Node2D) -> void: # player leave range.
	player = null # disables player tracking no target.
	playerChase = false # disables player chasing script.

func _physics_process(delta: float) -> void:
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
