extends RefCounted
class_name EnemyGen

## Procedural enemy generator.
## Takes the 4 base archetypes, assigns each a random element from the active
## run's pool, and derives resistance / weakness tags.
## Pure function — no side effects, no Node references.

# Blend factor: how strongly element color overrides the base archetype color.
const ELEMENT_TINT_FACTOR : float = 0.40


## Returns an Array[EnemyData] with one entry per archetype (4 total).
static func generate(rng: RandomNumberGenerator, elements: Array[ElementData]) -> Array[EnemyData]:
	var result: Array[EnemyData] = []

	# Build the list of element damage_tags for weakness lookup.
	var tags: Array[String] = []
	for elem: ElementData in elements:
		tags.append(elem.damage_tag)

	# One EnemyData per archetype; element assigned randomly.
	for arch_index in 4:
		var elem_index: int = rng.randi_range(0, elements.size() - 1)
		var elem: ElementData = elements[elem_index]

		# Weakness = a different element's tag.
		var weak_tag: String = ""
		if elements.size() > 1:
			var weak_index: int = rng.randi_range(0, elements.size() - 2)
			if weak_index >= elem_index:
				weak_index += 1
			weak_tag = elements[weak_index].damage_tag

		var d := EnemyData.new()
		d.element        = elem
		d.resistance_tag = elem.damage_tag
		d.weakness_tag   = weak_tag

		match arch_index:
			0:   # Basic
				d.type         = EnemyData.Type.BASIC
				d.display_name = "Basic"
				d.max_hp       = 100.0
				d.speed        = 80.0
				d.size         = Vector2(28.0, 28.0)
				d.gold_reward  = 10
				d.armor        = 0.0
				d.color        = Color(0.85, 0.20, 0.20).lerp(elem.color, ELEMENT_TINT_FACTOR)
			1:   # Fast
				d.type         = EnemyData.Type.FAST
				d.display_name = "Fast"
				d.max_hp       = 50.0
				d.speed        = 155.0
				d.size         = Vector2(22.0, 22.0)
				d.gold_reward  = 8
				d.armor        = 0.0
				d.color        = Color(0.95, 0.55, 0.10).lerp(elem.color, ELEMENT_TINT_FACTOR)
			2:   # Tank
				d.type         = EnemyData.Type.TANK
				d.display_name = "Tank"
				d.max_hp       = 400.0
				d.speed        = 38.0
				d.size         = Vector2(40.0, 40.0)
				d.gold_reward  = 25
				d.armor        = 0.30
				d.color        = Color(0.38, 0.18, 0.55).lerp(elem.color, ELEMENT_TINT_FACTOR)
			3:   # Swarm
				d.type         = EnemyData.Type.SWARM
				d.display_name = "Swarm"
				d.max_hp       = 25.0
				d.speed        = 125.0
				d.size         = Vector2(16.0, 16.0)
				d.gold_reward  = 5
				d.armor        = 0.0
				d.color        = Color(0.60, 0.85, 0.20).lerp(elem.color, ELEMENT_TINT_FACTOR)

		result.append(d)

	return result
