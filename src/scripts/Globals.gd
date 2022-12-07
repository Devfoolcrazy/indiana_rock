extends Node

var last_position: Vector2 = Vector2(450, 2)
var indications: Dictionary

# CURRENT LEVEL
var current_level_base = "/root/Game/"
var current_level: int = 1
var current_level_path: String = ""

# NODES
const wooden_sign_path: String = "res://src/components/Signs/WoodenSign.tscn"

var wooden_sign_level_1 : String = ""


func _ready() -> void:
	load_panel_indication_text()
	if current_level == 1:
		current_level_path = current_level_base + "Level1/"
	
	wooden_sign_level_1 = current_level_path + "WoodenSign"



func load_panel_indication_text():
	var file_path = "res://data/indication_panel/data.json"
	var file = File.new()
	
	assert(file.file_exists(file_path))
	
	file.open(file_path, file.READ)
	indications = parse_json(file.get_as_text())
	
	assert(indications.size() > 0)
