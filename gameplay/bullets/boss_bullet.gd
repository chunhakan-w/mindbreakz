extends Area2D

const BOSS_BULLET_SPEED = 250.0
var direction = Vector2.ZERO
var damage = 10

@onready var sprite = $AnimatedSprite2D

func _ready():
	# เริ่มเล่น animation
	if sprite:
		sprite.play()

func _physics_process(delta):
	position += direction * BOSS_BULLET_SPEED * delta

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage(damage)
		queue_free()
	elif body.is_in_group("ground"):
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
