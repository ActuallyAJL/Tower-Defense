extends Node2D
class_name Main

const TILE_SIZE : int = 48
const GRID_COLS : int = 20
const GRID_ROWS : int = 12

const COLOR_GRASS := Color(0.20, 0.40, 0.16)
const COLOR_PATH  := Color(0.52, 0.42, 0.27)
const COLOR_ENTRY := Color(0.18, 0.62, 0.22)
const COLOR_EXIT  := Color(0.72, 0.18, 0.18)
const COLOR_HOVER := Color(1.0,  0.90, 0.20, 0.30)
const COLOR_BLOCK := Color(1.0,  0.20, 0.20, 0.20)

var _entities     : Node2D
var _wave_manager : WaveManager
var _hud          : HUD

var _path_tiles   : Array[Vector2i] = []
var _path_set     : Dictionary = {}   # Vector2i → true
var _waypoints    : Array[Vector2] = []
var _occupied     : Dictionary = {}   # Vector2i → Tower


func _ready() -> void:
	GameState.reset()
	RunSeed.start_run(randi())

	_center_grid()
	_generate_map()

	_entities = Node2D.new()
	add_child(_entities)

	_wave_manager = WaveManager.new()
	_wave_manager.waypoints       = _waypoints
	_wave_manager.entities_parent = _entities
	add_child(_wave_manager)

	_hud = HUD.new()
	add_child(_hud)

	_wave_manager.wave_completed.connect(_hud.on_wave_completed)
	_wave_manager.all_waves_completed.connect(GameState.game_won.emit)
	_hud.start_wave_pressed.connect(_wave_manager.start_next_wave)


func _center_grid() -> void:
	var vp := get_viewport_rect().size
	position = Vector2(
		floorf((vp.x - GRID_COLS * TILE_SIZE) / 2.0),
		floorf((vp.y - GRID_ROWS * TILE_SIZE) / 2.0)
	)


func _generate_map() -> void:
	_path_tiles = PathGenerator.generate(GRID_COLS, GRID_ROWS, RunSeed.rng)
	for tile in _path_tiles:
		_path_set[tile] = true
	_waypoints.clear()
	for tile in _path_tiles:
		_waypoints.append(_tile_center(tile))
	queue_redraw()


# ---------------------------------------------------------------------------
# Per-frame
# ---------------------------------------------------------------------------

func _process(_delta: float) -> void:
	# Redraw every frame to animate portals and update hover highlight.
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var tile := _world_to_tile(get_local_mouse_position())
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				_try_place_tower(tile)
			MOUSE_BUTTON_RIGHT:
				_hud.deselect_tower()


# ---------------------------------------------------------------------------
# Tower placement
# ---------------------------------------------------------------------------

func _try_place_tower(tile: Vector2i) -> void:
	if _hud.selected_type < 0:
		return
	if not _can_place(tile):
		return
	var data := TowerData.create(_hud.selected_type as TowerData.Type)
	if not GameState.spend_gold(data.cost):
		return
	var tower := Tower.new()
	tower.data           = data
	tower.position       = _tile_center(tile)
	tower.enemies_parent = _entities
	_entities.add_child(tower)
	_occupied[tile] = tower


func _can_place(tile: Vector2i) -> bool:
	if tile.x < 0 or tile.x >= GRID_COLS or tile.y < 0 or tile.y >= GRID_ROWS:
		return false
	if _path_set.has(tile):
		return false
	if _occupied.has(tile):
		return false
	if _hud.selected_type < 0:
		return false
	return GameState.gold >= TowerData.create(_hud.selected_type as TowerData.Type).cost


# ---------------------------------------------------------------------------
# Drawing
# ---------------------------------------------------------------------------

func _draw() -> void:
	_draw_grid()
	_draw_portals()
	_draw_hover()


func _draw_grid() -> void:
	for row in GRID_ROWS:
		for col in GRID_COLS:
			var tile  := Vector2i(col, row)
			var color := _tile_color(tile)
			var rect  := Rect2(col * TILE_SIZE + 1, row * TILE_SIZE + 1,
							   TILE_SIZE - 2, TILE_SIZE - 2)
			draw_rect(rect, color)
			# Subtle inner bevel — slightly darker 1px border
			draw_rect(rect, color.darkened(0.18), false, 1.0)


func _draw_portals() -> void:
	if _path_tiles.is_empty():
		return
	var pulse := (sin(Time.get_ticks_msec() / 380.0) + 1.0) / 2.0  # 0→1 sine

	var entry_c := _tile_center(_path_tiles[0])
	draw_circle(entry_c, 10.0 + pulse * 5.0, Color(0.20, 1.0, 0.35, 0.45 + pulse * 0.25))

	var exit_c := _tile_center(_path_tiles[-1])
	draw_circle(exit_c, 10.0 + pulse * 5.0, Color(1.0, 0.22, 0.22, 0.45 + pulse * 0.25))


func _draw_hover() -> void:
	if _hud == null or _hud.selected_type < 0:
		return
	var tile := _world_to_tile(get_local_mouse_position())
	if tile.x < 0 or tile.x >= GRID_COLS or tile.y < 0 or tile.y >= GRID_ROWS:
		return
	var valid  := _can_place(tile)
	var color  := COLOR_HOVER if valid else COLOR_BLOCK
	draw_rect(
		Rect2(tile.x * TILE_SIZE + 1, tile.y * TILE_SIZE + 1, TILE_SIZE - 2, TILE_SIZE - 2),
		color
	)


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

func _tile_center(tile: Vector2i) -> Vector2:
	return Vector2(tile.x * TILE_SIZE + TILE_SIZE / 2.0,
				   tile.y * TILE_SIZE + TILE_SIZE / 2.0)


func _world_to_tile(local_pos: Vector2) -> Vector2i:
	return Vector2i(int(local_pos.x / TILE_SIZE), int(local_pos.y / TILE_SIZE))


func _tile_color(tile: Vector2i) -> Color:
	if not _path_tiles.is_empty():
		if tile == _path_tiles[0]:
			return COLOR_ENTRY
		if tile == _path_tiles[-1]:
			return COLOR_EXIT
	if _path_set.has(tile):
		return COLOR_PATH
	return COLOR_GRASS
