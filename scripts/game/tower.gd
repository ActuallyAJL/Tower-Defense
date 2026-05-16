extends Node2D
class_name Tower

const SIZE    := Vector2(36.0, 36.0)
const COLOR   := Color(0.3, 0.5, 0.85)

@export var damage    : float = 25.0
@export var range_px  : float = 160.0
@export var fire_rate : float = 1.0   # shots per second

# Set by the spawner so the tower can scan for enemies.
var enemies_parent: Node = null

var _cooldown : float = 0.0
var _target   : Enemy = null


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
	_cooldown = 1.0 / fire_rate


func _acquire_target() -> void:
	# Keep the current target if it's still alive and in range.
	if is_instance_valid(_target) and position.distance_to(_target.position) <= range_px:
		return
	_target = null
	if enemies_parent == null:
		return
	# Pick the closest enemy within range.
	var best_dist := range_px + 1.0
	for child in enemies_parent.get_children():
		if child is Enemy:
			var d := position.distance_to(child.position)
			if d < best_dist:
				best_dist = d
				_target = child as Enemy


func _fire() -> void:
	var proj := Projectile.new()
	proj.position = position
	proj.setup(_target, damage)
	# Add to the same parent so coordinates match.
	get_parent().add_child(proj)


func _draw() -> void:
	var half := SIZE / 2.0
	draw_rect(Rect2(-half, SIZE), COLOR)
	# Subtle range indicator.
	draw_arc(Vector2.ZERO, range_px, 0.0, TAU, 64, Color(COLOR, 0.15))
