extends Node
class_name WaveManager

signal wave_started(wave_num: int)
signal wave_completed(wave_num: int)
signal all_waves_completed

## Set by main.gd after path generation.
var waypoints      : Array[Vector2] = []
var entities_parent: Node = null

## Flat spawn queue for the active wave.
## Each entry: { "data": EnemyData, "delay": float, "hp_mult": float }
var _spawn_queue : Array = []
var _spawn_timer : float = 0.0
var _alive_count : int   = 0
var _wave_active : bool  = false


func start_next_wave() -> void:
	var wave_index: int = GameState.wave   # 0-based index before advancing
	if wave_index >= RunSeed.waves.size():
		return
	GameState.advance_wave()

	var wave_def: Dictionary = RunSeed.waves[wave_index]
	var hp_mult: float       = float(wave_def["hp_mult"])
	var entries: Array       = wave_def["entries"]

	# Expand spawn groups into a flat ordered spawn queue.
	# Groups are interleaved so different enemy types arrive mixed together,
	# giving a more interesting wave feel than dumping one type then the next.
	_spawn_queue = _interleave_groups(entries, hp_mult)
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
			var entry: Dictionary = _spawn_queue.pop_front()
			_spawn_enemy(entry["data"] as EnemyData, entry["hp_mult"] as float)
			# Load the NEXT entry's delay (not the just-spawned entry's delay).
			# Each entry's "delay" means: wait this long before spawning THIS entry.
			# After spawning, we prime the timer for the entry at the front of the queue.
			_spawn_timer = float(_spawn_queue[0]["delay"]) if _spawn_queue.size() > 0 else 0.0

	if _spawn_queue.is_empty() and _alive_count == 0:
		_wave_active = false
		var finished: int = GameState.wave
		wave_completed.emit(finished)
		if finished >= RunSeed.waves.size():
			all_waves_completed.emit()


## Expand a list of spawn-group Dicts into a flat, interleaved spawn list.
## Each group Dict: { "type": EnemyData, "count": int, "interval": float }
## Returns Array of { "data": EnemyData, "delay": float, "hp_mult": float }
func _interleave_groups(groups: Array, hp_mult: float) -> Array:
	# Build per-group queues then round-robin them.
	var queues: Array = []
	for g: Dictionary in groups:
		var q: Array = []
		var enemy_data: EnemyData = g["type"]
		var count: int            = int(g["count"])
		var interval: float       = float(g["interval"])
		for _i: int in count:
			q.append({"data": enemy_data, "delay": interval, "hp_mult": hp_mult})
		queues.append(q)

	var flat: Array = []
	var any_left := true
	while any_left:
		any_left = false
		for q: Array in queues:
			if q.size() > 0:
				flat.append(q.pop_front())
				any_left = true

	# Entry 0 is triggered by the wave-start timer (which starts at 0.0), so its
	# own delay field is never consumed.  Entries 1..N use their delay as the
	# wait period *before* they spawn (read from the queue front after each pop).

	return flat


func _spawn_enemy(enemy_data: EnemyData, hp_mult: float) -> void:
	if entities_parent == null or waypoints.is_empty():
		return
	var enemy := Enemy.new()
	enemy.setup(waypoints, enemy_data, hp_mult)
	# tree_exiting fires on queue_free() whether the enemy was killed or exited.
	enemy.tree_exiting.connect(_on_enemy_removed)
	entities_parent.add_child(enemy)
	_alive_count += 1


func _on_enemy_removed() -> void:
	_alive_count = maxi(_alive_count - 1, 0)
