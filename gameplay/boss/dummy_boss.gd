extends CharacterBody2D

# HP System
var max_hp = 100
var current_hp = 100
var boss_hp_bar = null

# State Machine
var state_machine = null

# Export variables
@export var max_hp_export: int = 100
@export var jump_speed: float = 400.0
@export var jump_height: float = 200.0
@export var move_duration: float = 1.0
@export var tired_duration: float = 5.0
@export var attack_delay: float = 3.0

# References
var player = null

func _ready():
	add_to_group("boss")
	
	# ตั้งค่า max_hp จาก export
	max_hp = max_hp_export
	current_hp = max_hp
	
	# หา HP bar
	boss_hp_bar = get_tree().get_first_node_in_group("boss_hp_bar")
	if boss_hp_bar:
		boss_hp_bar.set_max_hp(max_hp)
		boss_hp_bar.update_hp(current_hp)
	
	# หา Player
	player = get_tree().get_first_node_in_group("player")
	
	# สร้าง State Machine
	state_machine = Node.new()
	state_machine.set_script(preload("res://gameplay/boss/boss_state_machine.gd"))
	state_machine.init(self)
	add_child(state_machine)
	
	# ตั้งค่า export ให้ state machine
	state_machine.jump_speed = jump_speed
	state_machine.jump_height = jump_height
	state_machine.move_duration = move_duration
	state_machine.tired_duration = tired_duration
	state_machine.attack_delay = attack_delay

func _process(delta):
	# หา Player ถ้ายังไม่มี
	if not player:
		player = get_tree().get_first_node_in_group("player")
	
	# หา boss_hp_bar ถ้ายังไม่มี
	if not boss_hp_bar:
		boss_hp_bar = get_tree().get_first_node_in_group("boss_hp_bar")
		if boss_hp_bar:
			boss_hp_bar.set_max_hp(max_hp)
			boss_hp_bar.update_hp(current_hp)
	
	# อัปเดต State Machine
	if state_machine:
		state_machine._process(delta)

func take_damage(amount):
	# เช็คว่า Boss สามารถรับ damage ได้หรือไม่
	if state_machine and not state_machine.can_take_damage():
		print("Boss is invulnerable in state: ", state_machine.current_state)
		return
	
	current_hp -= amount
	if current_hp < 0:
		current_hp = 0
	
	# ค้นหา boss_hp_bar ใหม่ถ้ายังเป็น null
	if not boss_hp_bar:
		boss_hp_bar = get_tree().get_first_node_in_group("boss_hp_bar")
		print("Boss: Re-searching for boss_hp_bar, found: ", boss_hp_bar)
	
	if boss_hp_bar:
		boss_hp_bar.update_hp(current_hp)
	else:
		print("Boss: ERROR - boss_hp_bar is still null in take_damage!")
	
	print("Boss HP: ", current_hp, "/", max_hp)
	
	if current_hp <= 0:
		die()

func die():
	print("Boss defeated!")
	queue_free()
