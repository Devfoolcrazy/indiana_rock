extends KinematicBody2D

var velocity: Vector2 = Vector2.ZERO
var SPEED: float = 300
var CROUCH_SPEED = 200
var GRAVITY: int = 2000 #(speed*5 ?)
var JUMP_HEIGHT: int = 140
var JUMP_FORCE = -sqrt(2 * GRAVITY * JUMP_HEIGHT)
var RATE: int = -50
var EARTH_GRAVITY: float = 9.81
var FALL_MULTIPLIER: float = 2
var on_ladder: bool = false

var lives: int = 6

# Finite State Machine
enum PLAYER_STATES {
	FLOOR = 1, AIR, CROUCH, LADDER, DIE, TELEPORT
}


var current_player_state = PLAYER_STATES.AIR
var current_direction: float = 0

onready var standing_stance = $StandingShape
onready var crouching_stance = $CrouchingShape

signal damage_taken(current_lives)

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	var right_direction: float = Input.is_action_pressed("right")
	var left_direction: float = Input.is_action_pressed("left")
	current_direction = right_direction - left_direction

	match current_player_state:
		PLAYER_STATES.AIR:
			if is_on_floor() and velocity.y == 0:
				current_player_state = PLAYER_STATES.FLOOR
				continue
			elif should_climb_ladder():
				current_player_state = PLAYER_STATES.LADDER
				continue
			$Sprite.flip_h = current_direction > 0
			if current_direction != 0:
				$AnimationPlayer.play("jump")
				velocity.x = lerp(velocity.x, SPEED * current_direction, pow(2, delta*-RATE))
			if current_direction == 0:
				$AnimationPlayer.play("jump")
				velocity.x = lerp(velocity.x, 0, pow(2, delta*-RATE))
			move_and_fall(delta)
		PLAYER_STATES.FLOOR:
			if not is_on_floor():
				current_player_state = PLAYER_STATES.AIR
				continue
			elif should_climb_ladder():
				current_player_state = PLAYER_STATES.LADDER
				continue
			elif Input.is_action_pressed("down"):
				current_player_state = PLAYER_STATES.CROUCH
				continue
			if current_direction != 0 and not should_climb_ladder():
				if Input.is_action_pressed("down"):
					current_player_state = PLAYER_STATES.CROUCH
					continue

				$Sprite.flip_h = current_direction > 0
				$AnimationPlayer.play("walk")
				velocity.x = lerp(velocity.x, SPEED * current_direction, pow(2, delta*-RATE))
			if current_direction == 0:
				$AnimationPlayer.play("idle")
#				velocity.x = lerp(velocity.x, 0, pow(2, delta*-RATE))
				velocity.x = 0
			if Input.is_action_just_pressed("jump"):
				velocity.y = JUMP_FORCE
				$Sounds/Jump.play()
				current_player_state = PLAYER_STATES.AIR
			move_and_fall(delta)
		PLAYER_STATES.CROUCH:
			$AnimationPlayer.play("crouch")
			on_crouch()
			if current_direction != 0:
				$Sprite.flip_h = current_direction > 0
				velocity.x = lerp(velocity.x, CROUCH_SPEED * current_direction, pow(2, delta*-RATE))				
			if current_direction == 0:
				velocity.x = lerp(velocity.x, 0, pow(2, delta*-RATE))
			if !Input.is_action_pressed("down") and can_stand():
				on_stand()
				current_player_state = PLAYER_STATES.FLOOR
				continue
			if Input.is_action_pressed("down") and on_ladder:
				current_player_state = PLAYER_STATES.LADDER
				continue
			move_and_fall(delta)
		PLAYER_STATES.LADDER:
			on_stand()
			if not on_ladder:
				current_player_state = PLAYER_STATES.AIR
				continue
			elif is_on_floor() and Input.is_action_pressed("down"):
				current_player_state = PLAYER_STATES.FLOOR
				Input.action_release("down")
				Input.action_release("up")
				continue
			elif Input.is_action_just_pressed("jump"):
				Input.action_release("down")
				Input.action_release("up")
				velocity.y = JUMP_FORCE * 0.7
				current_player_state = PLAYER_STATES.AIR
				continue
			
			if Input.is_action_pressed("down") or Input.is_action_pressed("up") or Input.is_action_pressed("right") or Input.is_action_pressed("left"):
				$AnimationPlayer.play("climb")
			else:
				$AnimationPlayer.stop()
				
			if Input.is_action_pressed("up"):
				velocity.y = -SPEED
			elif Input.is_action_pressed("down"):
				velocity.y = SPEED
			else:
				velocity.y = lerp(velocity.y, 0, 0.2)
			
			if Input.is_action_pressed("left"):
				velocity.x = -SPEED / 6
			elif Input.is_action_pressed("right"):
				velocity.x = SPEED / 6
			else:
				velocity.x = lerp(velocity.x, 0, 0.2)
			
			
			velocity = move_and_slide(velocity, Vector2.UP)
		PLAYER_STATES.DIE:
			# On applique la gravité
			velocity.y += GRAVITY * delta
			velocity.y = clamp(velocity.y, -GRAVITY, GRAVITY)
			velocity.x = 0
			velocity = move_and_slide(velocity, Vector2.UP)
		
			# On joue l'animation die
			$AnimationPlayer.play("die")
			continue

			
			
	
func move_and_fall(delta: float) -> void:
	velocity.y += GRAVITY * delta
	velocity.y = clamp(velocity.y, -GRAVITY, GRAVITY)
	# Si le MC tombe, il tombe plus vite qu'il ne monte
	if velocity.y > 0:
		# On applique une gravité supplémentaire quand le MC tombe
		velocity += Vector2.UP * - EARTH_GRAVITY * FALL_MULTIPLIER
	velocity = move_and_slide(velocity, Vector2.UP)


func on_crouch() -> void:
		standing_stance.disabled = true
		crouching_stance.disabled = false


func on_stand() -> void:
		standing_stance.disabled = false
		crouching_stance.disabled = true

# SOURCE = https://www.youtube.com/watch?v=GPA_M3CoKCs
func can_stand() -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = Physics2DShapeQueryParameters.new()
	query.set_shape(standing_stance.shape)
	query.transform = standing_stance.global_transform
	query.collision_layer = collision_mask
	var results = space_state.intersect_shape(query)
	for i in range(results.size() -1, -1, -1):
		var collider = results[i].collider
		var shape = results[i].shape
		if collider is CollisionObject2D && collider.is_shape_owner_one_way_collision_enabled(shape):
			results.remove(i)
		elif collider is TileMap:
			var tile_id = collider.get_cellv(results[i].metadata)
			if collider.tile_set.tile_get_shape_one_way(tile_id, 0):
				results.remove(i)
	return results.size() == 0

func should_climb_ladder() -> bool:
	if on_ladder and (Input.is_action_pressed("up") or Input.is_action_pressed("down")):
		return true
	else:
		return false

func _on_LadderChecker_body_entered(_body: Node) -> void:
	on_ladder = true

func _on_LadderChecker_body_exited(_body: Node) -> void:
	on_ladder = false

func get_hurt() -> void:
	set_collision_layer_bit(0, false)
	lives -= 1
	emit_signal("damage_taken", lives)
	current_player_state = PLAYER_STATES.DIE
	

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "die":
		self.position = Globals.last_position
		current_player_state = PLAYER_STATES.FLOOR
		var t = Timer.new()
		t.set_wait_time(1)
		t.set_one_shot(true)
		get_parent().add_child(t)
		t.start()
		yield(t, "timeout")
		set_collision_layer_bit(0, true)


func get_current_direction() -> Vector2:
	return velocity


func read(msg: String):
	# Stocker les éléments lus comme une suite d'indice?
	print(msg)
