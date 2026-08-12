extends Area2D

const BULLET_SPEED = 500.0
var direction = 1

func _physics_process(delta):
	position.x += direction * BULLET_SPEED * delta

func _on_body_entered(body):
	if body.is_in_group("boss"):
		body.take_damage(5)
		queue_free()
	elif body.is_in_group("ground") or body is StaticBody2D:
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
