extends RefCounted
class_name ElementGen

## Procedural element generator.
## Draws 3–5 elements from the full pool of 6 using the seeded RNG.
## Pure function — no side effects, no Node references.

const POOL_SIZE    : int = 6
const MIN_ELEMENTS : int = 3
const MAX_ELEMENTS : int = 5


## Returns an Array[ElementData] of 3–5 elements drawn without replacement.
static func generate(rng: RandomNumberGenerator) -> Array[ElementData]:
	# Fisher–Yates shuffle on pool indices [0..5].
	var indices: Array[int] = [0, 1, 2, 3, 4, 5]
	for i in range(indices.size() - 1, 0, -1):
		var j: int = rng.randi_range(0, i)
		var tmp: int = indices[i]
		indices[i] = indices[j]
		indices[j] = tmp

	var count: int = rng.randi_range(MIN_ELEMENTS, MAX_ELEMENTS)
	var result: Array[ElementData] = []
	for k in count:
		result.append(_make_element(indices[k]))
	return result


## Build a single ElementData from a pool index (0–5).
static func _make_element(pool_index: int) -> ElementData:
	var e := ElementData.new()
	match pool_index:
		0:   # Fire
			e.element_name  = "Fire"
			e.color         = Color(0.95, 0.35, 0.10)
			e.damage_tag    = "fire"
			e.debuff_effect = "burn_dot"
			e.debuff_value  = 8.0
			e.synergy_bonus = "Adjacent Fire towers deal +20% damage"
		1:   # Ice
			e.element_name  = "Ice"
			e.color         = Color(0.45, 0.80, 1.00)
			e.damage_tag    = "ice"
			e.debuff_effect = "freeze_slow"
			e.debuff_value  = 0.35
			e.synergy_bonus = "Adjacent Ice towers apply double-duration freeze"
		2:   # Storm
			e.element_name  = "Storm"
			e.color         = Color(0.70, 0.50, 1.00)
			e.damage_tag    = "storm"
			e.debuff_effect = "stun"
			e.debuff_value  = 0.4
			e.synergy_bonus = "Adjacent Storm towers have +15% fire rate"
		3:   # Void
			e.element_name  = "Void"
			e.color         = Color(0.25, 0.10, 0.40)
			e.damage_tag    = "void"
			e.debuff_effect = "armor_shred"
			e.debuff_value  = 0.5
			e.synergy_bonus = "Adjacent Void towers pierce armor on every shot"
		4:   # Earth
			e.element_name  = "Earth"
			e.color         = Color(0.45, 0.30, 0.10)
			e.damage_tag    = "earth"
			e.debuff_effect = "root"
			e.debuff_value  = 1.5
			e.synergy_bonus = "Adjacent Earth towers gain +25% range"
		5:   # Light
			e.element_name  = "Light"
			e.color         = Color(1.00, 0.95, 0.50)
			e.damage_tag    = "light"
			e.debuff_effect = "heal_aura"
			e.debuff_value  = 5.0
			e.synergy_bonus = "Adjacent Light towers share 10% of kills as bonus gold"
		_:
			e.element_name  = "Unknown"
			e.color         = Color(0.5, 0.5, 0.5)
			e.damage_tag    = ""
			e.debuff_effect = ""
			e.debuff_value  = 0.0
			e.synergy_bonus = ""
	return e
