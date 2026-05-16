extends Node2D
class_name Tower

const BODY_SIZE    := Vector2(36.0, 36.0)
const BARREL_LEN   := 22.0   # pixels from centre to barrel tip
const BARREL_WIDTH := 4.0

var data: TowerData

var enemies_parent: Node = null

var _cooldown     : float = 0.0
var _target       : Enemy = null
var _barrel_angle : float = 0.0


func _ready() -> void:
	queue_redraw()


func _process(delta: float) -> void:
	_cooldown -= delta
	if _cooldown > 0.0:
		return
	_acquire_target()
	if not is_instance_valid(_target):
		return
	_fire()
	_cooldown = 1.0 / data.fire_rate


func _acquire_target() -> void:
	if is_instance_valid(_target) and position.distance_to(_target.position) <= data.range_px:
		return
	_target = null
	if enemies_parent == null:
		return
	var best_dist := data.range_px + 1.0
	for child in enemies_parent.get_children():
		if child is Enemy:
			var d := position.distance_to(child.position)
			if d < best_dist:
				best_dist = d
				_target = child as Enemy


func _fire() -> void:
	_barrel_angle = position.direction_to(_target.position).angle()
	queue_redraw()

	var proj := Projectile.new()
	proj.position = position
	proj.setup(
		_target,
		data.damage,
		data.pierce_armor,
		data.aoe_radius,
		data.slow_amount,
		data.slow_duration
	)
	get_parent().add_child(proj)


func _draw() -> void:
	if data == null:
		return
	var half := BODY_SIZE / 2.0

	# Base plate (slightly larger, darker)
	draw_rect(Rect2(-half - Vector2(2, 2), BODY_SIZE + Vector2(4, 4)), data.color.darkened(0.35))
	# Body
	draw_rect(Rect2(-half, BODY_SIZE), data.color)

	# Barrel
	var barrel_tip := Vector2(BARREL_LEN, 0.0).rotated(_barrel_angle)
	draw_line(Vector2.ZERO, barrel_tip, data.color.darkened(0.45), BARREL_WIDTH)

	# Range circle (faint)
	draw_arc(Vector2.ZERO, data.range_px, 0.0, TAU, 64, Color(data.color, 0.12))
