extends Node

# Boss State Machine
enum BossState {
	MOVE,
	ATTACK,
	TIRED
}

var current_state = BossState.MOVE
var boss: CharacterBody2D
var state_timer = 0.0

# Position system
var position_markers = []
var current_position_index = 0
var target_position = Vector2.ZERO
var is_moving = false

# Visual feedback
var boss_sprite = null
var state_label = null
var boss_animated_sprite = null

# Parameters
@export var jump_speed: float = 400.0
@export var jump_height: float = 200.0
@export var move_duration: float = 1.0
@export var tired_duration: float = 5.0
@export var attack_delay: float = 3.0

# Attack system
var boss_bullet_scene = preload("res://gameplay/bullets/boss_bullet.tscn")
var ground_wave_scene = preload("res://gameplay/boss/ground_wave.tscn")
var player = null

var attacks_per_cycle = 4
var attacks_completed = 0
var attack_timer = 0.0
var is_attacking = false

func init(boss_node):
	boss = boss_node
	name = "boss_state_machine"
	call_deferred("_setup_visual_feedback")

func _setup_visual_feedback():
	if boss and boss.is_inside_tree():
		boss_sprite = boss.get_node("AnimatedSprite2D")
		state_label = boss.get_node("StateLabel")
		_update_visual_feedback()

func set_markers(markers):
	position_markers = markers

func set_state(new_state):
	current_state = new_state
	state_timer = 0.0
	
	# รีเซ็ตค่าเมื่อเข้า TIRED
	if new_state == BossState.TIRED:
		is_attacking = false
		attacks_completed = 0
		attack_timer = 0.0
		print("Boss entered TIRED, reset attack counters")
	
	call_deferred("_update_visual_feedback")
	print("Boss state changed to: ", BossState.keys()[new_state])

func _process(delta):
	state_timer += delta
	_execute_state(delta)

func _execute_state(delta):
	match current_state:
		BossState.MOVE:
			_move_state(delta)
		BossState.ATTACK:
			_attack_state(delta)
		BossState.TIRED:
			_tired_state(delta)
	
	# หันหน้าหา player ทุก state
	_face_player()

func _move_state(_delta):
	if not is_moving:
		_start_move_to_new_position()
	else:
		# ระหว่างกระโดด (ให้ tween จัดการ)
		pass

func _start_move_to_new_position():
	if position_markers.is_empty():
		print("ERROR: No position markers found!")
		set_state(BossState.ATTACK)
		return
	
	# สุ่มตำแหน่งใหม่ ไม่ซ้ำจุดเดิม
	var new_index = current_position_index
	while new_index == current_position_index:
		new_index = randi() % position_markers.size()
	
	current_position_index = new_index
	target_position = position_markers[new_index].global_position
	is_moving = true
	
	print("Boss moving to position ", new_index, ": ", target_position)
	_jump_to_target()

func _jump_to_target():
	var tween = boss.create_tween()
	var duration = move_duration
	
	var start_pos = boss.global_position
	var distance = target_position - start_pos
	var mid_pos = start_pos + distance / 2
	mid_pos.y -= jump_height
	
	tween.parallel()
	tween.tween_property(boss, "global_position", mid_pos, duration / 2)
	tween.tween_property(boss, "global_position", target_position, duration / 2)
	tween.set_ease(Tween.EASE_OUT)
	
	tween.tween_callback(_on_jump_complete)

func _on_jump_complete():
	print("Boss jump completed, reached target")
	is_moving = false
	set_state(BossState.ATTACK)

func _attack_state(delta):
	if not is_attacking:
		# เริ่มโจมตี
		is_attacking = true
		attacks_completed = 0
		attack_timer = 0.0
		_perform_attack()
	else:
		# รอระหว่างท่า
		attack_timer += delta
		if attack_timer >= attack_delay:
			attack_timer = 0.0
			attacks_completed += 1
			
			if attacks_completed >= attacks_per_cycle:
				# ทำครบแล้ว เข้า TIRED
				print("Boss completed all attacks, entering TIRED state")
				is_attacking = false
				set_state(BossState.TIRED)
			else:
				# ทำท่าต่อ
				print("Boss continuing attacks (", attacks_completed, "/", attacks_per_cycle, ")")
				_perform_attack()

func _perform_attack():
	var attacks = ["shoot_3_bullets", "ground_slam"]
	var chosen_attack = attacks[randi() % attacks.size()]
	print("Boss chose attack: ", chosen_attack)
	
	match chosen_attack:
		"shoot_3_bullets":
			_shoot_3_bullets()
		"ground_slam":
			_ground_slam()

func _shoot_3_bullets():
	print("Boss: Mouth open animation")
	# ยิง 3 ลูก
	for i in range(3):
		_fire_bullet()
		await get_tree().create_timer(0.2).timeout
	print("Boss: Mouth close animation")
	await get_tree().create_timer(0.3).timeout

func _fire_bullet():
	if not player:
		player = get_tree().get_first_node_in_group("player")
	
	if player:
		var bullet = boss_bullet_scene.instantiate()
		boss.get_parent().add_child(bullet)
		bullet.global_position = boss.global_position
		
		var direction = (player.global_position - boss.global_position).normalized()
		bullet.direction = direction
		print("Boss fired bullet")

func _ground_slam():
	print("Boss: Ground slam animation")
	await get_tree().create_timer(0.5).timeout
	_release_ground_wave()

func _release_ground_wave():
	if not player:
		player = get_tree().get_first_node_in_group("player")
	
	if player:
		var wave = ground_wave_scene.instantiate()
		boss.get_parent().add_child(wave)
		wave.global_position = boss.global_position
		
		var direction = (player.global_position - boss.global_position).normalized()
		direction.y = 0
		if direction.x == 0:
			direction.x = 1
		
		wave.set_direction(direction)
		print("Boss released ground wave")

func _tired_state(_delta):
	if state_timer >= tired_duration:
		set_state(BossState.MOVE)

func _update_visual_feedback():
	if boss and boss.is_inside_tree():
		if not boss_sprite:
			boss_sprite = boss.get_node("Sprite2D")
		if not state_label:
			state_label = boss.get_node("StateLabel")
	
	if boss_sprite:
		match current_state:
			BossState.MOVE:
				boss_sprite.modulate = Color(0.5, 0.5, 1, 1)
			BossState.ATTACK:
				boss_sprite.modulate = Color(1, 0.3, 0.3, 1)
			BossState.TIRED:
				boss_sprite.modulate = Color(0.3, 1, 0.3, 1)
	
	if state_label:
		match current_state:
			BossState.MOVE:
				state_label.text = "MOVE"
			BossState.ATTACK:
				state_label.text = "ATTACK"
			BossState.TIRED:
				state_label.text = "VULNERABLE"

func can_take_damage() -> bool:
	return current_state == BossState.TIRED

func _face_player():
	if not player:
		player = get_tree().get_first_node_in_group("player")
	
	if player and boss_sprite:
		var direction = player.global_position.x - boss.global_position.x
		if direction > 0:
			boss_sprite.flip_h = false
		else:
			boss_sprite.flip_h = true
