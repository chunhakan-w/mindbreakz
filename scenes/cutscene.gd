extends Control

var story_images = []
var current_story_index = 0
var story_duration = 3.0  # เวลาแสดงแต่ละภาพ (วินาที)
var story_timer = 0.0
var is_playing = false
var can_skip = false

@onready var story_sprite = $StorySprite
@onready var bgm_player = $BGMPlayer

func _ready():
	# เชื่อมปุ่ม skip
	$SkipButton.pressed.connect(_on_skip_pressed)
	
	# ปิด sprite ก่อนเริ่ม
	story_sprite.visible = false
	
	# เริ่ม cutscene
	start_cutscene()

func start_cutscene():
	is_playing = true
	can_skip = false
	current_story_index = 0
	story_timer = 0.0
	
	# เล่น BGM
	if bgm_player:
		bgm_player.play()
	
	# เริ่มแสดงภาพ
	_play_story_sequence()

func _play_story_sequence():
	if current_story_index < 7:
		# แสดงภาพ
		_show_story_image(current_story_index)
		
		# รอเวลา
		await get_tree().create_timer(story_duration).timeout
		
		# ไปภาพถัดไป
		current_story_index += 1
		_play_story_sequence()
	else:
		# จบ cutscene
		_end_cutscene()

func _show_story_image(index):
	# โหลดภาพแบบ runtime
	var image_paths = [
		"res://story/story_1.png",
		"res://story/story_2.png",
		"res://story/story_3.png",
		"res://story/story_4.png",
		"res://story/story_5.png",
		"res://story/story_6.png",
		"res://story/story_7.png"
	]
	
	if index < image_paths.size():
		var new_texture = load(image_paths[index])
		if new_texture:
			story_sprite.texture = new_texture
			story_sprite.visible = true
		else:
			print("ERROR: Could not load story image ", index)

func _process(delta):
	if is_playing:
		# ตรวจสอบสำหรับ skip
		if Input.is_action_just_pressed("ui_cancel") and can_skip:
			_skip_cutscene()

func _on_skip_pressed():
	if can_skip:
		_skip_cutscene()

func _skip_cutscene():
	print("Cutscene skipped")
	_end_cutscene()

func _end_cutscene():
	is_playing = false
	
	# หยุด BGM
	if bgm_player:
		bgm_player.stop()
	
	# รอให้เสียงหยุด
	await get_tree().create_timer(0.5).timeout
	
	# ไป gameplay
	get_tree().change_scene_to_file("res://gameplay/gameplay_test.tscn")
