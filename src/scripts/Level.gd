extends Node2D

func _enter_tree() -> void:
	if Globals.last_position != Vector2.ZERO:
		$Player.global_position = Globals.last_position
