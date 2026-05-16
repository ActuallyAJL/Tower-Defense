extends Node2D
class_name Main

const TILE_SIZE: int = 48
const GRID_COLS: int = 20
const GRID_ROWS: int = 12

const COLOR_GRASS  := Color(0.22, 0.42, 0.18)
const COLOR_BORDER := Color(0.15, 0.30, 0.12)


func _ready() -> void:
	_center_grid()


func _center_grid() -> void:
	var vp := get_viewport_rect().size
	position = Vector2(
		floorf((vp.x - GRID_COLS * TILE_SIZE) / 2.0),
		floorf((vp.y - GRID_ROWS * TILE_SIZE) / 2.0)
	)


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
