extends KinematicBody2D


var velocity: Vector2 = Vector2.ZERO
var SPEED: int = 50

var EARTH_GRAVITY: float = 9.81
var FALL_MULTIPLIER: float = 2
var GRAVITY: int = 2000 #(speed*5 ?)
enum DIRECTION {
	LEFT=-1, RIGHT=1, 
}
export var direction: int = DIRECTION.RIGHT
export var is_enemy_detects_cliffs: bool = true

func _ready() -> void:
	if direction == -1:
		$AnimatedSprite.flip_h = true
		
	$CliffDetection.position.x = ($CollisionShape2D.shape.get_extents().x) * direction
	$CliffDetection.enabled = is_enemy_detects_cliffs
		
func _physics_process(delta: float) -> void:
	if is_on_wall() or not $CliffDetection.is_colliding() and is_enemy_detects_cliffs and is_on_floor():
		direction = direction * -1
		$AnimatedSprite.flip_h = !$AnimatedSprite.flip_h
		$CliffDetection.position.x = ($CollisionShape2D.shape.get_extents().x) * direction
	

	velocity.x = SPEED * direction
	
	move_and_fall(delta)
	
func move_and_fall(delta: float) -> void:
	velocity.y += GRAVITY * delta
	velocity.y = clamp(velocity.y, -GRAVITY, GRAVITY)
	# Si le MC tombe, il tombe plus vite qu'il ne monte
	if velocity.y > 0:
		# On applique une gravité supplémentaire quand le MC tombe
		velocity += Vector2.UP * - EARTH_GRAVITY * FALL_MULTIPLIER
	velocity = move_and_slide(velocity, Vector2.UP)


func _on_HurtChecker_body_entered(body: Node) -> void:
	if body.has_method("get_hurt"):
		body.get_hurt()
