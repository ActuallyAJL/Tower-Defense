extends Node2D
class_name Enemy

signal died(enemy: Enemy)

const SPEED := 80.0
const SIZE  := Vector2(28.0, 28.0)
const COLOR := Color(0.85, 0.2, 0.2)

@export var max_hp: float = 100.0

var hp: float

var _waypoints: Array[Vector2] = []
var _wp_index: int = 0


func _ready() -> void:
	hp = max_hp


func setup(waypoints: Array[Vector2]) -> void:
	_waypoints = waypoints
	_wp_index = 0
	if _waypoints.size() > 0:
		position = _waypoints[0]


func _process(delta: float) -> void:
	_move(delta)
	queue_redraw()


func _move(delta: float) -> void:
	if _wp_index >= _waypoints.size():
		queue_free()
		return
	var target := _waypoints[_wp_index]
	if position.distance_to(target) < 2.0:
		_wp_index += 1
		return
	position += (target - position).normalized() * SPEED * delta


func take_damage(amount: float) -> void:
	hp = maxf(hp - amount, 0.0)
	if hp == 0.0:
		died.emit(self)
		queue_free()


func _draw() -> void:
	var half := SIZE / 2.0
	# Body
	draw_rect(Rect2(-half, SIZE), COLOR)
	# HP bar backing
	draw_rect(
		Rect2(Vector2(-half.x, -half.y - 9.0), Vector2(SIZE.x, 5.0)),
		Color(0.15, 0.15, 0.15)
	)
	# HP bar fill — shrinks as hp drops
	draw_rect(
		Rect2(Vector2(-half.x, -half.y - 9.0), Vector2(SIZE.x * (hp / max_hp), 5.0)),
		Color(0.15, 0.9, 0.15)
	)
