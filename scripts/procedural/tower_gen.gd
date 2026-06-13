extends RefCounted
class_name TowerGen

## Procedural tower generator.
## Produces 6–8 unique towers per run by crossing archetypes with elements
## and rolling stats within archetype-specific ranges.
## Pure function — no side effects, no Node references.

const MIN_TOWERS : int = 6
const MAX_TOWERS : int = 8

const ARCH_SHOOTER : String = "Shooter"
const ARCH_SNIPER  : String = "Sniper"
const ARCH_SLOW    : String = "Slow"
const ARCH_AOE     : String = "AoE"

const ARCHETYPE_KEYS: Array[String] = ["Shooter", "Sniper", "Slow", "AoE"]


## Returns an Array[TowerData] of 6–8 procedurally generated towers.
## elements must be the active run's element list from ElementGen.generate().
static func generate(rng: RandomNumberGenerator, elements: Array[ElementData]) -> Array[TowerData]:
	var count: int = rng.randi_range(MIN_TOWERS, MAX_TOWERS)
	var result: Array[TowerData] = []

	# Shuffle archetype pool so required order varies each run.
	var arch_pool: Array[String] = ARCHETYPE_KEYS.duplicate()
	for i in range(arch_pool.size() - 1, 0, -1):
		var j: int = rng.randi_range(0, i)
		var tmp: String = arch_pool[i]
		arch_pool[i] = arch_pool[j]
		arch_pool[j] = tmp

	for i in count:
		var arch: String
		if i < arch_pool.size():
			arch = arch_pool[i]
		else:
			arch = ARCHETYPE_KEYS[rng.randi_range(0, ARCHETYPE_KEYS.size() - 1)]
		var elem: ElementData = elements[rng.randi_range(0, elements.size() - 1)]
		result.append(_make_tower(rng, arch, elem))

	return result


static func _make_tower(rng: RandomNumberGenerator, arch: String, elem: ElementData) -> TowerData:
	var d := TowerData.new()
	d.archetype     = arch
	d.element       = elem
	d.damage_tag    = elem.damage_tag

	match arch:
		ARCH_SHOOTER:
			d.damage        = rng.randf_range(18.0, 40.0)
			d.range_px      = rng.randf_range(140.0, 200.0)
			d.fire_rate     = rng.randf_range(0.8, 1.6)
			d.cost          = rng.randi_range(40, 75)
			d.aoe_radius    = 0.0
			d.slow_amount   = 0.0
			d.slow_duration = 0.0
			d.pierce_armor  = false
			var words_s: Array[String] = ["Cannon", "Turret", "Rifle", "Bolter", "Lance"]
			d.tower_name = "%s %s" % [elem.element_name, words_s[rng.randi_range(0, words_s.size() - 1)]]
			d.color = Color(0.40, 0.45, 0.55).lerp(elem.color, 0.55)

		ARCH_SNIPER:
			d.damage        = rng.randf_range(75.0, 140.0)
			d.range_px      = rng.randf_range(240.0, 340.0)
			d.fire_rate     = rng.randf_range(0.35, 0.65)
			d.cost          = rng.randi_range(90, 140)
			d.aoe_radius    = 0.0
			d.slow_amount   = 0.0
			d.slow_duration = 0.0
			d.pierce_armor  = true
			var words_n: Array[String] = ["Piercer", "Sniper", "Javelin", "Needle", "Arrow"]
			d.tower_name = "%s %s" % [elem.element_name, words_n[rng.randi_range(0, words_n.size() - 1)]]
			d.color = Color(0.20, 0.25, 0.35).lerp(elem.color, 0.55)

		ARCH_SLOW:
			d.damage        = rng.randf_range(6.0, 18.0)
			d.range_px      = rng.randf_range(110.0, 160.0)
			d.fire_rate     = rng.randf_range(0.6, 1.0)
			d.cost          = rng.randi_range(60, 90)
			d.aoe_radius    = 0.0
			d.slow_amount   = 0.45
			d.slow_duration = 2.0
			d.pierce_armor  = false
			var words_w: Array[String] = ["Pulse", "Web", "Trap", "Coil", "Mire"]
			d.tower_name = "%s %s" % [elem.element_name, words_w[rng.randi_range(0, words_w.size() - 1)]]
			d.color = Color(0.25, 0.65, 0.75).lerp(elem.color, 0.55)

		ARCH_AOE:
			d.damage        = rng.randf_range(40.0, 80.0)
			d.range_px      = rng.randf_range(120.0, 170.0)
			d.fire_rate     = rng.randf_range(0.30, 0.55)
			d.cost          = rng.randi_range(100, 150)
			d.aoe_radius    = 85.0
			d.slow_amount   = 0.0
			d.slow_duration = 0.0
			d.pierce_armor  = false
			var words_a: Array[String] = ["Bastion", "Nova", "Burst", "Mortar", "Bomb"]
			d.tower_name = "%s %s" % [elem.element_name, words_a[rng.randi_range(0, words_a.size() - 1)]]
			d.color = Color(0.70, 0.40, 0.15).lerp(elem.color, 0.55)

		_:
			d.damage        = 20.0
			d.range_px      = 150.0
			d.fire_rate     = 1.0
			d.cost          = 50
			d.aoe_radius    = 0.0
			d.slow_amount   = 0.0
			d.slow_duration = 0.0
			d.pierce_armor  = false
			d.tower_name    = "%s Tower" % elem.element_name
			d.color         = elem.color

	return d
