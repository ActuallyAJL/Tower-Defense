extends Node2D
class_name Main

const TILE_SIZE : int = 48
const GRID_COLS : int = 20
const GRID_ROWS : int = 12

const COLOR_GRASS := Color(0.22, 0.42, 0.18)
const COLOR_PATH  := Color(0.55, 0.45, 0.30)
const COLOR_ENTRY := Color(0.25, 0.75, 0.30)
const COLOR_EXIT  := Color(0.85, 0.25, 0.25)

var _entities : Node2D
var _path_tiles: Array[Vector2i] = []
var _path_set  : Dictionary = {}  # Vector2i → true, for O(1) tile lookup


func _ready() -> void:
	_center_grid()
	_generate_map()
	_entities = Node2D.new()
	add_child(_entities)
	_spawn_demo()


func _center_grid() -> void:
	var vp := get_viewport_rect().size
	position = Vector2(
		floorf((vp.x - GRID_COLS * TILE_SIZE) / 2.0),
		floorf((vp.y - GRID_ROWS * TILE_SIZE) / 2.0)
	)


func _generate_map() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 12345  # fixed for now; will come from RunSeed in a later step
	_path_tiles = PathGenerator.generate(GRID_COLS, GRID_ROWS, rng)
	for tile in _path_tiles:
		_path_set[tile] = true
	queue_redraw()


func _tile_center(tile: Vector2i) -> Vector2:
	return Vector2(tile.x * TILE_SIZE + TILE_SIZE / 2.0,
				   tile.y * TILE_SIZE + TILE_SIZE / 2.0)


func _spawn_demo() -> void:
	if _path_tiles.is_empty():
		return

	# Enemy follows the generated path tile-by-tile.
	var waypoints: Array[Vector2] = []
	for tile in _path_tiles:
		waypoints.append(_tile_center(tile))

	var enemy := Enemy.new()
	enemy.setup(waypoints)
	_entities.add_child(enemy)

	# Place a tower on an off-path tile adjacent to the path near column 10.
	var tower := Tower.new()
	tower.position = _find_tower_spot()
	tower.enemies_parent = _entities
	_entities.add_child(tower)


func _find_tower_spot() -> Vector2:
	# Scan columns near the middle for an off-path tile that borders the path,
	# so the demo tower is guaranteed to be in range.
	var mid := GRID_COLS / 2
	for col in range(mid - 4, mid + 4):
		for row in range(GRID_ROWS):
			var tile := Vector2i(col, row)
			if _path_set.has(tile):
				continue
			for nb in [Vector2i(col+1,row), Vector2i(col-1,row),
					   Vector2i(col,row+1), Vector2i(col,row-1)]:
				if _path_set.has(nb):
					return _tile_center(tile)
	return Vector2(10 * TILE_SIZE + TILE_SIZE / 2.0, 2 * TILE_SIZE + TILE_SIZE / 2.0)


func _draw() -> void:
	for row in GRID_ROWS:
		for col in GRID_COLS:
			draw_rect(
				Rect2(col * TILE_SIZE + 1, row * TILE_SIZE + 1, TILE_SIZE - 2, TILE_SIZE - 2),
				_tile_color(Vector2i(col, row))
			)


func _tile_color(tile: Vector2i) -> Color:
	if not _path_tiles.is_empty():
		if tile == _path_tiles[0]:
			return COLOR_ENTRY
		if tile == _path_tiles[-1]:
			return COLOR_EXIT
	if _path_set.has(tile):
		return COLOR_PATH
	return COLOR_GRASS
