extends Node2D


var above_ladder: bool = false

func _physics_process(_delta: float) -> void:
	if above_ladder and Input.is_action_pressed("down"):
		$LadderTop.rotation_degrees = 180
	else:
		$LadderTop.rotation_degrees = 0

func _on_IsPlayerAbove_body_entered(_body: Node) -> void:
	above_ladder = true


func _on_IsPlayerAbove_body_exited(_body: Node) -> void:
	above_ladder = false
