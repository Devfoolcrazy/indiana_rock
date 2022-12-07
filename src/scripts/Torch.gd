extends Light2D

onready var noise = OpenSimplexNoise.new()
var value: float = 0.0
const MAX_VALUE: int = 1000000

func _ready() -> void:
	randomize()
	value = randi() % MAX_VALUE
	noise.period = 20
	
func _physics_process(_delta: float) -> void:
	value += 1
	if value > MAX_VALUE:
		value = 0.0
	var alpha = ((noise.get_noise_1d(value) + 1) / 4.0) + 0.5
	self.color = Color(color.r, color.g, color.b, alpha)


