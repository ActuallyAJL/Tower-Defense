extends Node2D
class_name Enemy

signal died(enemy: Enemy)

var data: EnemyData

var hp: float

var _waypoints  : Array[Vector2] = []
var _wp_index   : int = 0
var _slow_timer : float = 0.0
var _slow_factor: float = 1.0


func setup(waypoints: Array[Vector2], enemy_data: EnemyData) -> void:
	data        = enemy_data
	hp          = data.max_hp
	_waypoints  = waypoints
	_wp_index   = 0
	if _waypoints.size() > 0:
		position = _waypoints[0]


func apply_slow(factor: float, duration: float) -> void:
	_slow_factor = factor
	_slow_timer  = duration


func take_damage(amount: float, pierce_armor: bool = false) -> void:
	var effective := amount * (1.0 - data.armor) if not pierce_armor else amount
	hp = maxf(hp - effective, 0.0)
	queue_redraw()
	if hp == 0.0:
		GameState.earn_gold(data.gold_reward)
		died.emit(self)
		queue_free()


func _process(delta: float) -> void:
	if _slow_timer > 0.0:
		_slow_timer -= delta
		if _slow_timer <= 0.0:
			_slow_factor = 1.0
	_move(delta)
	queue_redraw()


func _move(delta: float) -> void:
	if _wp_index >= _waypoints.size():
		GameState.lose_life()
		queue_free()
		return
	var target := _waypoints[_wp_index]
	if position.distance_to(target) < 2.0:
		_wp_index += 1
		return
	position += (target - position).normalized() * data.speed * _slow_factor * delta


func _draw() -> void:
	if data == null:
		return
	var half := data.size / 2.0

	# Body
	draw_rect(Rect2(-half, data.size), data.color)

	# Slow tint
	if _slow_timer > 0.0:
		draw_rect(Rect2(-half, data.size), Color(0.30, 0.60, 1.0, 0.40))

	# HP bar backing
	var bar_w := data.size.x
	draw_rect(
		Rect2(Vector2(-half.x, -half.y - 9.0), Vector2(bar_w, 5.0)),
		Color(0.12, 0.12, 0.12)
	)
	# HP bar fill
	draw_rect(
		Rect2(Vector2(-half.x, -half.y - 9.0), Vector2(bar_w * (hp / data.max_hp), 5.0)),
		Color(0.15, 0.90, 0.15)
	)
