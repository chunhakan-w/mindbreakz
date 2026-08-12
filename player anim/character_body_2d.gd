extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var is_facing_left: bool = false
var is_attacking: bool = false
var is_x_pressed: bool = false

func _physics_process(delta: float) -> void:
	# เช็กการปล่อยปุ่ม X
	if not Input.is_key_pressed(KEY_X):
		is_x_pressed = false

	# ระบบแรงโน้มถ่วง
	if not is_on_floor():
		velocity += get_gravity() * delta

	# ระบบกดปุ่ม X เพื่อต่อย
	if Input.is_key_pressed(KEY_X) and not is_x_pressed:
		is_x_pressed = true
		punch_attack()

	# ระบบกระโดด
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# รับค่าการกดปุ่มซ้าย-ขวา (สามารถเดินขณะต่อยได้ปกติ)
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		is_facing_left = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	update_sprite_visibility(direction)

func punch_attack() -> void:
	is_attacking = true
	
	# แสดงแอนิเมชันต่อย
	$punch.flip_h = is_facing_left
	$punch.show()
	$punch.play()
	
	# ระยะเวลาแสดงท่าต่อย (0.3 วินาที)
	await get_tree().create_timer(0.3).timeout
	
	is_attacking = false

func update_sprite_visibility(direction: float) -> void:
	$idle.flip_h = is_facing_left
	$run.flip_h = is_facing_left
	$jump.flip_h = is_facing_left
	$punch.flip_h = is_facing_left

	# ซ่อนภาพทั้งหมดก่อน
	$idle.hide()
	$run.hide()
	$jump.hide()
	$punch.hide()
	
	# ถ้ากำลังต่อย ให้โชว์ท่าต่อยเป็นหลัก
	if is_attacking:
		$punch.show()
	elif not is_on_floor():
		$jump.show()
		$jump.play()
	elif direction != 0:
		$run.show()
		$run.play()
	else:
		$idle.show()
		$idle.play()
