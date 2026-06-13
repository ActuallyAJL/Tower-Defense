extends RefCounted
class_name WaveGen

## Procedural wave generator.
## Generates 10–14 waves whose composition shifts from early (easy) to late (hard).
## HP scaling: each wave multiplies base enemy HP by 1.0 + wave_index * HP_SCALE_STEP.
##
## Output format — RunSeed.waves is an Array where each element is a Dictionary:
##   {
##     "hp_mult"  : float,          -- HP multiplier for every enemy in this wave
##     "entries"  : Array           -- Array of spawn-group Dictionaries:
##                                     { "type": EnemyData, "count": int, "interval": float }
##   }
##
## WaveManager expands entries into a flat spawn queue at wave-start time.

const MIN_WAVES      : int   = 10
const MAX_WAVES      : int   = 14
const HP_SCALE_STEP  : float = 0.15   # +15% HP per wave index

# Archetype indices into the enemy_types array (mirrors EnemyGen.ARCHETYPES order).
const IDX_BASIC : int = 0
const IDX_FAST  : int = 1
const IDX_TANK  : int = 2
const IDX_SWARM : int = 3

# Phase thresholds (fraction of total wave count).
const EARLY_END : float = 0.35   # first 35% of waves = early phase
const MID_END   : float = 0.70   # next 35% = mid phase; last 30% = late


## Returns an Array of wave definition Dictionaries.
static func generate(rng: RandomNumberGenerator, enemy_types: Array[EnemyData]) -> Array:
	var total: int = rng.randi_range(MIN_WAVES, MAX_WAVES)
	var waves: Array = []

	for i: int in total:
		var phase: float = float(i) / float(total - 1) if total > 1 else 0.0
		var hp_mult: float = 1.0 + i * HP_SCALE_STEP

		var entries: Array = []
		if phase <= EARLY_END:
			entries = _make_early_wave(rng, enemy_types, i)
		elif phase <= MID_END:
			entries = _make_mid_wave(rng, enemy_types, i)
		else:
			entries = _make_late_wave(rng, enemy_types, i)

		waves.append({"hp_mult": hp_mult, "entries": entries})

	return waves


# ---------------------------------------------------------------------------
# Phase builders
# ---------------------------------------------------------------------------

## Early waves: Basic + Fast only, small counts, relaxed intervals.
static func _make_early_wave(rng: RandomNumberGenerator, types: Array[EnemyData], idx: int) -> Array:
	var entries: Array = []
	var base_count: int = 4 + idx * 2   # 4, 6, 8 …

	# Mostly Basic, some Fast from wave 2 onward.
	entries.append(_group(types[IDX_BASIC], rng.randi_range(base_count, base_count + 2), 1.1))
	if idx >= 1:
		entries.append(_group(types[IDX_FAST], rng.randi_range(2, 4 + idx), 0.75))

	return entries


## Mid waves: all four types, growing counts, moderate intervals.
static func _make_mid_wave(rng: RandomNumberGenerator, types: Array[EnemyData], idx: int) -> Array:
	var entries: Array = []
	var base_count: int = 6 + idx * 2

	entries.append(_group(types[IDX_BASIC], rng.randi_range(base_count, base_count + 4), 0.85))
	entries.append(_group(types[IDX_FAST],  rng.randi_range(4, 8 + idx),                 0.60))
	entries.append(_group(types[IDX_TANK],  rng.randi_range(1, 2 + idx / 3),              1.40))
	entries.append(_group(types[IDX_SWARM], rng.randi_range(6, 12 + idx * 2),             0.35))

	return entries


## Late waves: Tank/Swarm heavy, large counts, tight intervals.
static func _make_late_wave(rng: RandomNumberGenerator, types: Array[EnemyData], idx: int) -> Array:
	var entries: Array = []
	var base_count: int = 10 + idx * 3

	entries.append(_group(types[IDX_SWARM], rng.randi_range(base_count, base_count + 10), 0.25))
	entries.append(_group(types[IDX_TANK],  rng.randi_range(4, 6 + idx / 2),              1.10))
	entries.append(_group(types[IDX_FAST],  rng.randi_range(8, 14 + idx),                 0.50))
	entries.append(_group(types[IDX_BASIC], rng.randi_range(base_count / 2, base_count),  0.70))

	return entries


static func _group(enemy: EnemyData, count: int, interval: float) -> Dictionary:
	return {"type": enemy, "count": maxi(count, 1), "interval": interval}
