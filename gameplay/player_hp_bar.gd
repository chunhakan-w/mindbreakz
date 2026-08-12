extends Control

var max_hp = 100
var current_hp = 100

func _ready():
	add_to_group("player_hp_bar")
	# เช็คว่ามี ProgressBar หรือไม่
	if has_node("ProgressBar"):
		print("PlayerHPBar: ProgressBar found")
		update_hp(current_hp)
	else:
		print("PlayerHPBar: ERROR - ProgressBar not found!")

func set_max_hp(value):
	max_hp = value
	if has_node("ProgressBar"):
		$ProgressBar.max_value = max_hp
		update_hp(current_hp)

func update_hp(value):
	current_hp = value
	
	print("PlayerHPBar update_hp called: ", current_hp, "/", max_hp)
	
	# อัปเดต ProgressBar
	if has_node("ProgressBar"):
		$ProgressBar.value = current_hp
		print("PlayerHPBar ProgressBar value set to: ", $ProgressBar.value)
	else:
		print("PlayerHPBar ERROR: ProgressBar not found in update_hp")
	
	# อัปเดตตัวเลข HP
	if has_node("HPLabel"):
		$HPLabel.text = str(current_hp) + "/" + str(max_hp)
	
	# เปลี่ยนสีตาม HP
	var hp_percentage = float(current_hp) / float(max_hp)
	if hp_percentage > 0.5:
		$ProgressBar.modulate = Color(1, 1, 1, 1)
	elif hp_percentage > 0.25:
		$ProgressBar.modulate = Color(1, 1, 0.8, 1)
	else:
		$ProgressBar.modulate = Color(1, 0.8, 0.8, 1)
