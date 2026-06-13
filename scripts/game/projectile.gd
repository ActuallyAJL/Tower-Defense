extends Node2D
class_name Projectile

const SPEED  := 220.0
const RADIUS := 5.0
const COLOR  := Color(1.0, 0.90, 0.20)

var _target       : Enemy
var _damage       : float
var _pierce_armor : bool
var _aoe_radius   : float
var _slow_amount  : float
var _slow_duration: float
var _damage_tag   : String   ## elemental tag forwarded to enemy.take_damage()


func setup(
	target        : Enemy,
	damage        : float,
	pierce_armor  : bool   = false,
	aoe_radius    : float  = 0.0,
	slow_amount   : float  = 0.0,
	slow_duration : float  = 0.0,
	damage_tag    : String = ""
) -> void:
	_target        = target
	_damage        = damage
	_pierce_armor  = pierce_armor
	_aoe_radius    = aoe_radius
	_slow_amount   = slow_amount
	_slow_duration = slow_duration
	_damage_tag    = damage_tag


func _process(delta: float) -> void:
	if not is_instance_valid(_target):
		queue_free()
		return
	var to_target := _target.position - position
	if to_target.length() <= RADIUS + SPEED * delta:
		_on_impact()
		return
	position += to_target.normalized() * SPEED * delta
	queue_redraw()


func _on_impact() -> void:
	var impact_pos := position

	# Primary hit
	if is_instance_valid(_target):
		_target.take_damage(_damage, _pierce_armor, _damage_tag)
		if _slow_amount > 0.0 and is_instance_valid(_target):
			_target.apply_slow(_slow_amount, _slow_duration)

	# AoE splash
	if _aoe_radius > 0.0:
		for child in get_parent().get_children():
			if child is Enemy and child != _target:
				if impact_pos.distance_to(child.position) <= _aoe_radius:
					child.take_damage(_damage, _pierce_armor, _damage_tag)

	queue_free()


func _draw() -> void:
	draw_circle(Vector2.ZERO, RADIUS, COLOR)
