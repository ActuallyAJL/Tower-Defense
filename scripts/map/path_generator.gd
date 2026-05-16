extends RefCounted
class_name PathGenerator

## Generates an ordered list of grid tile coordinates forming a path
## from the left edge (col 0) to the right edge (col cols-1).
##
## The algorithm alternates between horizontal runs and vertical turns,
## staying at least one tile from the top and bottom edges so towers
## have room to be placed alongside the path.
static func generate(cols: int, rows: int, rng: RandomNumberGenerator) -> Array[Vector2i]:
	var path: Array[Vector2i] = []
	var pos := Vector2i(0, rng.randi_range(1, rows - 2))
	path.append(pos)

	while pos.x < cols - 1:
		# Horizontal run: 2–5 steps right, clamped to grid edge.
		var h_steps := mini(rng.randi_range(2, 5), cols - 1 - pos.x)
		for _i in h_steps:
			pos.x += 1
			path.append(pos)

		if pos.x >= cols - 1:
			break

		# Vertical turn: bias direction away from the nearest edge.
		var dir := 1 if rng.randf() > 0.5 else -1
		if pos.y <= 1:
			dir = 1
		elif pos.y >= rows - 2:
			dir = -1

		var v_steps := rng.randi_range(1, 3)
		for _i in v_steps:
			var ny := pos.y + dir
			if ny < 1 or ny >= rows - 1:
				break
			pos.y = ny
			path.append(pos)

	return path
