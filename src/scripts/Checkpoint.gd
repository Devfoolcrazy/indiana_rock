extends Area2D

var is_activated: bool = false

func _on_CheckpointPole_body_entered(_body: Node) -> void:
	if is_activated == false:
		Globals.last_position = global_position
		$CheckpointDiscovered.play()
		is_activated = true
