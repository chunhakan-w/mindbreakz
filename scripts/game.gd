extends Control

func _ready():
	$VBoxContainer/BackButton.pressed.connect(_on_back_pressed)
	$VBoxContainer/StartGameplayButton.pressed.connect(_on_start_gameplay_pressed)

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_start_gameplay_pressed():
	# ไป cutscene ก่อน แล้วค่อยไป gameplay
	get_tree().change_scene_to_file("res://scenes/cutscene.tscn")
