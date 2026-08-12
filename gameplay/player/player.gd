extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const DASH_SPEED = 600.0
const DASH_DURATION = 0.2
const GRAVITY = 1200.0
const MAX_HP = 100
const INVINCIBILITY_TIME = 1.0

# Melee Attack System
const ATTACK_DAMAGE = 5
const ATTACK_DURATION = 0.2
const ATTACK_COOLDOWN = 0.3
const ATTACK_RANGE = 60.0

var is_dashing = false
var dash_timer = 0.0
var can_dash = true
var dash_cooldown = 1.0
var dash_cooldown_timer = 0.0
var facing_right = true

# Attack System
var is_attacking = false
var attack_timer = 0.0
var can_attack = true
var attack_cooldown_timer = 0.0
var attack_hitbox = null

# HP System
var current_hp = MAX_HP
var is_invincible = false
var invincibility_timer = 0.0
var player_hp_bar = null

# Animation sprites
@onready var idle_sprite = $idle
@onready var jump_sprite = $jump
@onready var run_sprite = $run
@onready var punch_sprite = $punch

@export var attack_damage: int = 5
@export var attack_range: float = 60.0
@export var attack_duration: float = 0.2
@export var attack_cooldown: float = 0.3

func _ready():
	add_to_group("player")
	# หา Player HP bar จาก parent scene
	player_hp_bar = get_tree().get_first_node_in_group("player_hp_bar")
	if player_hp_bar:
		player_hp_bar.set_max_hp(MAX_HP)
		player_hp_bar.update_hp(current_hp)
	
	# สร้าง attack hitbox
	attack_hitbox = $AttackHitbox
	attack_hitbox.monitoring = false
	attack_hitbox.monitorable = false
	
	# แสดง sprite idle เท่านั้น
	_show_sprite("idle")

func _physics_process(delta):
	# จัดการอมตะ
	if is_invincible:
		invincibility_timer -= delta
		if invincibility_timer <= 0:
			is_invincible = false
			modulate = Color(1, 1, 1, 1)
		else:
			modulate = Color(1, 1, 1, 0.5) if fmod(invincibility_timer, 0.1) < 0.05 else Color(1, 1, 1, 1)
	
	# เพิ่มแรงโน้มถ่วง
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# กระโดด
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# การเคลื่อนที่ซ้าย/ขวา
	var direction = Input.get_axis("move_left", "move_right")
	
	if not is_dashing:
		if direction:
			velocity.x = direction * SPEED
			# หันตัว
			if direction > 0:
				facing_right = true
				_flip_sprites(false)
			else:
				facing_right = false
				_flip_sprites(true)
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		velocity.x = DASH_SPEED if facing_right else -DASH_SPEED

	# Dash
	if Input.is_action_just_pressed("dash") and can_dash and is_on_floor():
		is_dashing = true
		dash_timer = DASH_DURATION
		can_dash = false
		dash_cooldown_timer = dash_cooldown

	# จัดการ dash timer
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false

	# จัดการ dash cooldown
	if not can_dash:
		dash_cooldown_timer -= delta
		if dash_cooldown_timer <= 0:
			can_dash = true

	# โจมตี
	if Input.is_action_just_pressed("attack") and can_attack:
		attack()

	# จัดการ attack timer
	if is_attacking:
		attack_timer -= delta
		if attack_timer <= 0:
			end_attack()

	# จัดการ attack cooldown
	if not can_attack:
		attack_cooldown_timer -= delta
		if attack_cooldown_timer <= 0:
			can_attack = true

	# Animation state
	if not is_attacking:
		if not is_on_floor():
			_show_sprite("jump")
		elif direction != 0:
			_show_sprite("run")
		else:
			_show_sprite("idle")

	move_and_slide()

func attack():
	is_attacking = true
	attack_timer = attack_duration
	can_attack = false
	attack_cooldown_timer = attack_cooldown
	
	# เล่น animation ตี
	_show_sprite("punch")
	
	# เปิด attack hitbox
	attack_hitbox.set_deferred("monitoring", true)
	attack_hitbox.set_deferred("monitorable", true)
	
	# ตำแหน่ง hitbox ตามทิศทาง
	if facing_right:
		attack_hitbox.position.x = attack_range / 2
	else:
		attack_hitbox.position.x = -attack_range / 2
	
	print("Player attacking!")

func end_attack():
	is_attacking = false
	# ปิด attack hitbox
	attack_hitbox.set_deferred("monitoring", false)
	attack_hitbox.set_deferred("monitorable", false)

func _show_sprite(sprite_name):
	# ซ่อนทุก sprite
	idle_sprite.visible = false
	jump_sprite.visible = false
	run_sprite.visible = false
	punch_sprite.visible = false
	
	# แสดง sprite ที่ต้องการ
	match sprite_name:
		"idle":
			idle_sprite.visible = true
			idle_sprite.play("default")
		"jump":
			jump_sprite.visible = true
			jump_sprite.play("default")
		"run":
			run_sprite.visible = true
			run_sprite.play("default")
		"punch":
			punch_sprite.visible = true
			punch_sprite.play("default")

func _flip_sprites(flip):
	idle_sprite.flip_h = flip
	jump_sprite.flip_h = flip
	run_sprite.flip_h = flip
	punch_sprite.flip_h = flip

func _on_attack_hitbox_body_entered(body):
	if body.is_in_group("boss"):
		body.take_damage(attack_damage)
		print("Player hit boss for ", attack_damage, " damage!")
		# ปิด hitbox ทันทีเพื่อไม่ให้โดนหลายครั้ง
		attack_hitbox.set_deferred("monitoring", false)
		attack_hitbox.set_deferred("monitorable", false)

func take_damage(amount):
	if is_invincible:
		return
	
	current_hp -= amount
	if current_hp < 0:
		current_hp = 0
	
	# ค้นหา player_hp_bar ใหม่ถ้ายังเป็น null
	if not player_hp_bar:
		player_hp_bar = get_tree().get_first_node_in_group("player_hp_bar")
		print("Player: Re-searching for player_hp_bar, found: ", player_hp_bar)
	
	if player_hp_bar:
		player_hp_bar.update_hp(current_hp)
	else:
		print("Player: ERROR - player_hp_bar is still null in take_damage!")
	
	print("Player HP: ", current_hp, "/", MAX_HP)
	
	if current_hp <= 0:
		die()
	else:
		# เริ่มอมตะ
		is_invincible = true
		invincibility_timer = INVINCIBILITY_TIME

func die():
	print("Player died!")
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")
