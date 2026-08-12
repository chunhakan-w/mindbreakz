extends Control

var death_delay = 3.0  # โหลดาวนหลังจาก boss ตาย
var death_timer = 0.0

func _ready():
	$VBoxContainer/RetryButton.pressed.connect(_on_retry_pressed)
	$VBoxContainer/MenuButton.pressed.connect(_on_menu_pressed)
	
	# เริ่มนับเวลา death
	death_timer = death_delay
	# ปิดปุ่มชั่วคราว
	$VBoxContainer/RetryButton.visible = false
	$VBoxContainer/MenuButton.visible = false

func _process(delta):
	if death_timer > 0:
		death_timer -= delta
		# แสดงนับถอยองหลัง
		$VBoxContainer/TitleLabel.text = "You Died!\nReturning in " + str(ceil(death_timer)) + "..."
	else:
		# แสดงปุ่ม
		$VBoxContainer/TitleLabel.text = "Game Over"
		$VBoxContainer/RetryButton.visible = true
		$VBoxContainer/MenuButton.visible = true

func _on_retry_pressed():
	get_tree().change_scene_to_file("res://gameplay/gameplay_test.tscn")

func _on_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
