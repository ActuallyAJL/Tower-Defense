extends Node2D
class_name Main

const TILE_SIZE : int = 48
const GRID_COLS : int = 20
const GRID_ROWS : int = 12

const COLOR_GRASS  := Color(0.22, 0.42, 0.18)
const COLOR_BORDER := Color(0.15, 0.30, 0.12)

# All game entities live under this node so they share the grid coordinate space.
var _entities: Node2D


func _ready() -> void:
	_center_grid()
	_entities = Node2D.new()
	add_child(_entities)
	_spawn_demo()


func _center_grid() -> void:
	var vp := get_viewport_rect().size
	position = Vector2(
		floorf((vp.x - GRID_COLS * TILE_SIZE) / 2.0),
		floorf((vp.y - GRID_ROWS * TILE_SIZE) / 2.0)
	)


func _spawn_demo() -> void:
	# Straight path along the middle row of the grid.
	var mid_y := (GRID_ROWS / 2) * TILE_SIZE + TILE_SIZE / 2.0
	var waypoints: Array[Vector2] = []
	for col in GRID_COLS:
		waypoints.append(Vector2(col * TILE_SIZE + TILE_SIZE / 2.0, mid_y))

	var enemy := Enemy.new()
	enemy.setup(waypoints)
	_entities.add_child(enemy)

	# Tower sits three rows above the path at column 10.
	var tower := Tower.new()
	tower.position = Vector2(10 * TILE_SIZE + TILE_SIZE / 2.0, 3 * TILE_SIZE + TILE_SIZE / 2.0)
	tower.enemies_parent = _entities
	_entities.add_child(tower)


func _draw() -> void:
	for row in GRID_ROWS:
		for col in GRID_COLS:
			var rect := Rect2(
				col * TILE_SIZE + 1,
				row * TILE_SIZE + 1,
				TILE_SIZE - 2,
				TILE_SIZE - 2
			)
			draw_rect(rect, COLOR_GRASS)
