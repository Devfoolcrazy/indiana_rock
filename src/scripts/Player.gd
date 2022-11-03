extends KinematicBody2D

var velocity: Vector2 = Vector2.ZERO
var speed: int = 200
var maxSpeed: int = 300
var jumpHeight = 700
var maxFallSpeed = 800
var slidePower: int = -50
var gravity: int = 20


func _process(delta: float) -> void:
	walk(delta)
	jump()
	apply_gravity(delta)
	velocity = move_and_slide(velocity, Vector2.UP)


func walk(delta: float) -> void:
	# get_action_strength permet de doser le mouvement sur un gamepad par exemple
	var right_direction: float = Input.is_action_pressed("right")
	var left_direction: float = Input.is_action_pressed("left")
	var direction: float = right_direction - left_direction
	# Si le personnage n'est pas immobile
	if direction != 0:
		# On applique la direction pour en faire un mouvement horizontal
		velocity.x += direction * speed * (delta*5)
		velocity.x = clamp(velocity.x, -maxSpeed, maxSpeed)
		# On applique le flip du sprite selon la direction
		$AnimatedSprite.flip_h = direction < 0
		# On anime la marche
		$AnimatedSprite.play("walk")
	else:
		velocity.x = lerp(0, velocity.x, pow(2, -50 * delta))
		$AnimatedSprite.play("idle")


func apply_gravity(delta: float) -> void:
	# On applique la gravité à notre personnage
	velocity.y += gravity 
	velocity.y = clamp(velocity.y, -maxFallSpeed, maxFallSpeed)


func jump()-> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y -= jumpHeight


