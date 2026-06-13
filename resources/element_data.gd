extends Resource
class_name ElementData

## Pure data resource describing a single element in the current run's element pool.
## All fields are set by ElementGen.generate() — never mutate after creation.

var element_name  : String   ## e.g. "Fire", "Ice"
var color         : Color    ## used to tint towers / enemies with this element
var damage_tag    : String   ## e.g. "fire", "ice" — matched against resistance/weakness
var debuff_effect : String   ## one of: "burn_dot", "freeze_slow", "stun", "armor_shred", "root", "heal_aura"
var debuff_value  : float    ## magnitude: DoT dps, slow factor, stun duration, etc.
var synergy_bonus : String   ## human-readable description of the adjacency synergy
