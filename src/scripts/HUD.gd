extends CanvasLayer

var lives: int = 6
var bombs: int = 6
var bullets: int = 6
var score: int = 600

onready var label_lives := $Interface/HBoxContainer/LivesCounter/Label
onready var label_bombs := $Interface/HBoxContainer/BombsCounter/Label
onready var label_bullets := $Interface/HBoxContainer/BulletsCounter/Label
onready var label_score := $Interface/ScoreCounter/Label


func _ready() -> void:
	label_lives.text = String(lives)
	label_bombs.text = String(bombs)
	label_bullets.text = String(bullets)
	label_score.text = String(score)
	
	# Se connecte au Player
	# TODO rendre cette connection plus générique
	var _s = get_parent().get_child(2).connect("damage_taken", self, "update_lives")


func update_lives(p_lives) -> void:
	lives = p_lives
#	_ready()
	label_lives.text = String(lives)
	

