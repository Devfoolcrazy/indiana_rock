extends Area2D


var wooden_sign = load(Globals.wooden_sign_path)
export var message_id: String = "001"
var can_interact: bool = false
var is_active: bool = false
var interactable_body: Node = null


func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	mc_read_message(interactable_body)

func _on_IndicationPanel_body_entered(body: Node) -> void:
	if body.has_method("read"):
		$Label.percent_visible = 0
		$Label.visible = true
		$Tween.interpolate_property(
			$Label, "percent_visible", 0, 1, 0.3,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
		)
		$Tween.start()
		can_interact = true
		interactable_body = body


func _on_IndicationPanel_body_exited(body: Node) -> void:
	if body.has_method("read"):
		$Tween.stop_all()
		$Label.percent_visible = 1
		$Tween.interpolate_property(
			$Label, "percent_visible", 1, 0, 0.3,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
		)
		$Tween.start()
		interactable_body = null
		can_interact = false
		

func mc_read_message(body:Node) -> void:
	var wooden_sign_instance = null
	if can_interact and Input.is_action_pressed("crouch") and is_active == false:
		wooden_sign_instance = wooden_sign.instance()
		print(wooden_sign_instance)
		is_active = true
		var player_position = body.global_position
		wooden_sign_instance.rect_position.x = player_position[0]
		wooden_sign_instance.rect_position.y = player_position[1] - 60
		$Label.visible = false
		var wooden_sign_label = wooden_sign_instance.get_child(1)
		var wooden_sign_tr = wooden_sign_instance.get_child(0)
		wooden_sign_label.text = Globals.indications[message_id].text
		$Tween.interpolate_property(
			wooden_sign_label, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 1,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
		)
		$Tween.interpolate_property(
			wooden_sign_tr, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 1,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
		)
		$Tween.start()
		get_parent().add_child(wooden_sign_instance)
		
	elif can_interact == false and is_active == true:
		if get_tree().get_root().has_node(Globals.wooden_sign_level_1):
			var wooden_sign_node = get_tree().get_root().get_node(Globals.wooden_sign_level_1)
			var wooden_sign_label = wooden_sign_node.get_child(1)
			var wooden_sign_tr = wooden_sign_node.get_child(0)
			$Tween.interpolate_property(
			wooden_sign_label, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 1,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
			)
			$Tween.interpolate_property(
				wooden_sign_tr, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 1,
				Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
			)
			$Tween.start()
			Utils.wait_for_queue_free(self, 1, wooden_sign_node)
			is_active = false

