extends Node2D

func _ready():
	# ตั้งค่ากล้องให้ติดตาม player
	var camera = $Camera2D
	var _player = $Player
	
	# ใช้ Godot's built-in camera following
	camera.make_current()
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 5.0
	
	# ตั้งค่าขอบเขตกล้อง
	var level_width = 2000
	var level_height = 1000
	camera.limit_left = 0
	camera.limit_right = level_width
	camera.limit_top = 0
	camera.limit_bottom = level_height
	
	# ส่ง markers ให้ boss state machine
	var boss = $DummyBoss
	var boss_markers = [$BossPointLeft, $BossPointCenter, $BossPointRight]
	
	# รอ boss สร้าง state machine
	await get_tree().process_frame
	if boss.has_node("boss_state_machine"):
		var state_machine = boss.get_node("boss_state_machine")
		state_machine.set_markers(boss_markers)
		print("Boss markers set successfully")

func _process(_delta):
	# กด ESC เพื่อกลับเมนู
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
