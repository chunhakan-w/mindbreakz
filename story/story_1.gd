extends Node2D

var images = [
	preload("res://story/story_1.png"),
	preload("res://story/story_2.png"),
	preload("res://story/story_3.png"),
	preload("res://story/story_4.png"),
	preload("res://story/story_5.png"),
	preload("res://story/story_6.png"),
	preload("res://story/story_7.png")
]

var current_image := 0

@onready var image_rect = $TextureRect
@onready var timer = $Timer

func _ready():
	show_image()

func show_image():
	if current_image >= images.size():
		start_boss()
		return

	image_rect.texture = images[current_image]

func _on_timer_timeout():
	current_image += 1
	show_image()

func start_boss():
	get_tree().change_scene_to_file("res://gameplay/gameplay_test.tscn")


func _on_next_button_pressed():
	print("NEXT PRESSED")
	current_image += 1
	show_image()
