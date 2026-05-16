extends Node2D
class_name Projectile

const SPEED  := 220.0
const RADIUS := 5.0
const COLOR  := Color(1.0, 0.85, 0.1)

var _target : Enemy
var _damage : float


func setup(target: Enemy, damage: float) -> void:
	_target = target
	_damage = damage


func _process(delta: float) -> void:
	if not is_instance_valid(_target):
		queue_free()
		return
	var to_target := _target.position - position
	# Close enough to register a hit.
	if to_target.length() <= RADIUS + SPEED * delta:
		_target.take_damage(_damage)
		queue_free()
		return
	position += to_target.normalized() * SPEED * delta
	queue_redraw()


func _draw() -> void:
	draw_circle(Vector2.ZERO, RADIUS, COLOR)
