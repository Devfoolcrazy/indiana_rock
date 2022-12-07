extends Node

class_name Utils

static func wait_for_queue_free(parent_node, s, n):
	print(n)
	var t = Timer.new()
	t.set_wait_time(s)
	t.set_one_shot(true)
	parent_node.add_child(t)
	t.start()
	yield(t, "timeout")
	t.queue_free()
	n.queue_free()

#SOURCE : https://www.reddit.com/r/godot/comments/emnpwk/is_there_a_way_to_get_the_collision_position_from/
#func _on_Area2D_body_shape_entered(body_id, body, body_shape, area_shape):
#	var body_shape_owner_id = body.shape_find_owner(body_shape)
#	var body_shape_owner = body.shape_owner_get_owner(body_shape_owner_id)
#	var body_shape_2d = body.shape_owner_get_shape(body_shape_owner_id, 0)
#	var body_global_transform = body_shape_owner.global_transform
#
#	var area_shape_owner_id = shape_find_owner(area_shape)
#	var area_shape_owner = shape_owner_get_owner(area_shape_owner_id)
#	var area_shape_2d = shape_owner_get_shape(area_shape_owner_id, 0)
#	var area_global_transform = area_shape_owner.global_transform
#
#	var collision_points = area_shape_2d.collide_and_get_contacts(area_global_transform,
#									body_shape_2d,
#									body_global_transform)
#	print(collision_points)
