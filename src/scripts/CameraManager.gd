extends Area2D


export var portal_id: String = "000-000"
export var panel_id: String = "000"

onready var camera = get_parent().get_node("Camera2D") as Camera2D

# TODO relocaliser locations dans un JSON externe
var locations = {
	"000": { "coordinates": Vector2(0,0), "connected_to":{"001": {"direction": "right"}, "002":{"direction": "down"}}},
	"001": { "coordinates": Vector2(1024,0), "connected_to":{"000": {"direction": "left"}, "003": {"direction": "right"}}},
	"002": { "coordinates": Vector2(0,600), "connected_to":{"000": {"direction": "up"}, "004": {"direction": "right"}}},
	"003": { "coordinates": Vector2(2028,0), "connected_to":{"001": {"direction": "left"}}},
	"004": { "coordinates": Vector2(1024,600), "connected_to":{"002": {"direction": "left"}}},
}


func _on_CameraManager_body_entered(body: Node) -> void:
	var next_panel_id: String = "NC"
	var next_coordinates: Vector2 = Vector2.ZERO
	var direction: String = "NC"
	var origin:String = portal_id.split("-")[0]
	var destination:String = portal_id.split("-")[1]
	
	if panel_id == origin:
		direction = locations[panel_id].connected_to[destination].direction
		next_coordinates = locations[destination].coordinates
		panel_id = destination
		
	else:
		direction = locations[destination].connected_to[origin].direction
		next_coordinates = locations[origin].coordinates
		panel_id = origin
		
	set_player_global_position_after_portal(body, direction)
	
	$Tween.interpolate_property(
			camera, "offset", camera.offset, next_coordinates, 0.5,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
		)
	$Tween.start()
	yield($Tween, "tween_completed")


func set_player_global_position_after_portal(body: Node, direction: String) -> void:
	match direction:
		"right":
			body.global_position.x += 35
		"left":
			body.global_position.x -= 35
		"up":
			body.global_position.y -= 75
		"down":
			body.global_position.y += 75
#
