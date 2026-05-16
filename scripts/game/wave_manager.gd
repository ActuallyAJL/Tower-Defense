extends Node
class_name WaveManager

signal wave_started(wave_num: int)
signal wave_completed(wave_num: int)
signal all_waves_completed

# Set by main.gd after path generation.
var waypoints      : Array[Vector2] = []
var entities_parent: Node = null

var _spawn_queue : Array = []   # each entry: [EnemyData.Type, delay_seconds]
var _spawn_timer : float = 0.0
var _alive_count : int   = 0
var _wave_active : bool  = false

# Shorthand aliases used in WAVES to keep lines short.
const B := EnemyData.Type.BASIC
const F := EnemyData.Type.FAST
const T := EnemyData.Type.TANK
const S := EnemyData.Type.SWARM

# Each wave is a flat ordered list of [EnemyData.Type, delay_before_spawn].
# The first entry always has delay 0.0 (spawns immediately when the wave starts).
const WAVES: Array = [
	# Wave 1 — 6× Basic
	[[B,0.0],[B,1.2],[B,1.2],[B,1.2],[B,1.2],[B,1.2]],
	# Wave 2 — 8× Basic + 4× Fast interleaved
	[[B,0.0],[F,1.0],[B,0.7],[F,1.0],[B,0.7],[F,1.0],[B,0.7],[F,1.0],
	 [B,0.7],[B,1.0],[B,1.0],[B,1.0]],
	# Wave 3 — 6× Basic + 6× Fast + 1× Tank
	[[B,0.0],[B,1.0],[F,0.7],[B,0.7],[F,0.7],[B,0.7],[F,0.7],[B,0.7],
	 [F,0.7],[F,0.7],[F,0.7],[B,0.8],[B,0.8],[T,2.0]],
	# Wave 4 — 12× Fast + 3× Tank
	[[F,0.0],[F,0.6],[F,0.6],[T,1.5],[F,0.6],[F,0.6],[F,0.6],[T,1.5],
	 [F,0.6],[F,0.6],[F,0.6],[F,0.6],[F,0.6],[F,0.6],[T,2.0]],
	# Wave 5 — 20× Swarm + 4× Basic
	[[S,0.0],[S,0.35],[S,0.35],[S,0.35],[B,0.8],[S,0.35],[S,0.35],[S,0.35],
	 [S,0.35],[B,0.8],[S,0.35],[S,0.35],[S,0.35],[S,0.35],[B,0.8],[S,0.35],
	 [S,0.35],[S,0.35],[S,0.35],[S,0.35],[S,0.35],[S,0.35],[S,0.35],[B,1.0]],
	# Wave 6 — 6× Tank + 10× Fast + 15× Swarm
	[[S,0.0],[S,0.35],[S,0.35],[F,0.6],[S,0.35],[T,1.5],[F,0.6],[S,0.35],
	 [F,0.6],[T,1.5],[S,0.35],[S,0.35],[F,0.6],[T,1.5],[F,0.6],[S,0.35],
	 [S,0.35],[F,0.6],[T,1.5],[F,0.6],[S,0.35],[T,1.5],[F,0.6],[S,0.35],
	 [F,0.6],[S,0.35],[F,0.6],[S,0.35],[S,0.35],[T,2.0],[T,2.0]],
	# Wave 7 — 12× Fast + 6× Tank + 25× Swarm
	[[S,0.0],[S,0.3],[S,0.3],[F,0.5],[S,0.3],[F,0.5],[T,1.2],[S,0.3],
	 [F,0.5],[S,0.3],[F,0.5],[T,1.2],[S,0.3],[S,0.3],[F,0.5],[S,0.3],
	 [T,1.2],[F,0.5],[S,0.3],[S,0.3],[F,0.5],[T,1.2],[S,0.3],[F,0.5],
	 [S,0.3],[T,1.2],[F,0.5],[S,0.3],[S,0.3],[F,0.5],[T,1.2],[F,0.5],
	 [S,0.3],[S,0.3],[F,0.5],[S,0.3],[S,0.3],[S,0.3],[F,0.5],[S,0.3],
	 [S,0.3],[S,0.3],[F,0.5]],
	# Wave 8 — Boss: 25× Basic + 15× Fast + 10× Tank + 40× Swarm
	[[S,0.0],[S,0.25],[S,0.25],[B,0.8],[S,0.25],[F,0.5],[S,0.25],[B,0.8],
	 [T,1.0],[S,0.25],[F,0.5],[S,0.25],[B,0.8],[S,0.25],[F,0.5],[T,1.0],
	 [S,0.25],[B,0.8],[S,0.25],[F,0.5],[S,0.25],[T,1.0],[B,0.8],[S,0.25],
	 [F,0.5],[S,0.25],[T,1.0],[B,0.8],[S,0.25],[F,0.5],[S,0.25],[T,1.0],
	 [B,0.8],[F,0.5],[S,0.25],[T,1.0],[B,0.8],[F,0.5],[S,0.25],[T,1.0],
	 [B,0.8],[F,0.5],[S,0.25],[S,0.25],[T,1.0],[B,0.8],[F,0.5],[S,0.25],
	 [S,0.25],[T,1.0],[B,0.8],[F,0.5],[S,0.25],[S,0.25],[B,0.8],[F,0.5],
	 [S,0.25],[S,0.25],[B,0.8],[S,0.25],[F,0.5],[S,0.25],[B,0.8],[S,0.25],
	 [T,1.0],[F,0.5],[B,0.8],[F,0.5],[T,1.0],[F,0.5],[B,0.8],[T,1.0],
	 [F,0.5],[B,0.8],[T,1.0],[F,0.5],[B,0.8],[F,0.5],[B,0.8],[F,0.5],
	 [B,0.8],[B,0.8],[B,0.8]],
]


func start_next_wave() -> void:
	var wave_index := GameState.wave  # 0-based before advance
	if wave_index >= WAVES.size():
		return
	GameState.advance_wave()
	_spawn_queue = WAVES[wave_index].duplicate()
	_spawn_timer = 0.0
	_alive_count = 0
	_wave_active = true
	wave_started.emit(GameState.wave)


func _process(delta: float) -> void:
	if not _wave_active:
		return

	if _spawn_queue.size() > 0:
		_spawn_timer -= delta
		if _spawn_timer <= 0.0:
			var entry: Array = _spawn_queue.pop_front()
			_spawn_enemy(entry[0] as EnemyData.Type)
			_spawn_timer = float(_spawn_queue[0][1]) if _spawn_queue.size() > 0 else 0.0

	if _spawn_queue.is_empty() and _alive_count == 0:
		_wave_active = false
		var finished := GameState.wave
		wave_completed.emit(finished)
		if finished >= WAVES.size():
			all_waves_completed.emit()


func _spawn_enemy(type: EnemyData.Type) -> void:
	if entities_parent == null or waypoints.is_empty():
		return
	var enemy := Enemy.new()
	enemy.setup(waypoints, EnemyData.create(type))
	# tree_exiting fires on queue_free() whether the enemy was killed or exited the map.
	enemy.tree_exiting.connect(_on_enemy_removed)
	entities_parent.add_child(enemy)
	_alive_count += 1


func _on_enemy_removed() -> void:
	_alive_count = maxi(_alive_count - 1, 0)
