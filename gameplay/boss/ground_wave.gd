extends Area2D

var direction = Vector2(1, 0)
var speed = 400.0
var damage = 15

@onready var sprite = $Sprite2D

func _ready():
	# เริ่มเล่น animation ถ้าเป็น AnimatedSprite2D
	if sprite and sprite is AnimatedSprite2D:
		sprite.play()

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage(damage)
		queue_free()

func _process(delta):
	position += direction * speed * delta

func set_direction(dir):
	direction = dir.normalized()
	# หัน sprite ตามทิศทาง
	if sprite:
		if direction.x > 0:
			sprite.flip_h = false
		elif direction.x < 0:
			sprite.flip_h = true

func set_wave_speed(spd):
	speed = spd

func set_wave_damage(dmg):
	damage = dmg
