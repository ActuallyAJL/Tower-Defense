extends Resource
class_name TowerData

## Pure data resource for a single tower type.
## Procedural instances are created by TowerGen.generate().
## The legacy Type enum and create() factory are kept for reference but are no
## longer used at runtime — the shop and placement code reads RunSeed.tower_roster.

enum Type { BASIC, SNIPER, SLOW, BOMB }

# Core identity
var tower_name   : String        ## procedural name, e.g. "Frost Cannon"
var archetype    : String        ## "Shooter" | "Sniper" | "Slow" | "AoE"
var element      : ElementData   ## assigned element (may be null for legacy use)
var damage_tag   : String        ## mirrors element.damage_tag; "" = untyped

# Stats
var damage       : float
var range_px     : float
var fire_rate    : float   # shots per second
var color        : Color
var cost         : int
var aoe_radius   : float   # 0 = single target
var slow_amount  : float   # speed multiplier applied to hit enemy (0.5 = half speed)
var slow_duration: float   # seconds the slow lasts
var pierce_armor : bool    # ignores enemy armor stat

# Kept for backward-compat tooling / tests.  Not called during a normal run.
var type: Type


## Legacy factory — not used during procedural runs.
static func create(t: Type) -> TowerData:
	var d := TowerData.new()
	d.type         = t
	d.aoe_radius   = 0.0
	d.slow_amount  = 0.0
	d.slow_duration = 0.0
	d.pierce_armor  = false
	d.damage_tag    = ""
	d.element       = null
	match t:
		Type.BASIC:
			d.tower_name   = "Basic"
			d.archetype    = "Shooter"
			d.damage       = 25.0
			d.range_px     = 160.0
			d.fire_rate    = 1.0
			d.color        = Color(0.30, 0.50, 0.85)
			d.cost         = 50
		Type.SNIPER:
			d.tower_name   = "Sniper"
			d.archetype    = "Sniper"
			d.damage       = 100.0
			d.range_px     = 280.0
			d.fire_rate    = 0.5
			d.color        = Color(0.15, 0.25, 0.60)
			d.cost         = 100
			d.pierce_armor = true
		Type.SLOW:
			d.tower_name   = "Slow"
			d.archetype    = "Slow"
			d.damage       = 10.0
			d.range_px     = 130.0
			d.fire_rate    = 0.8
			d.color        = Color(0.20, 0.80, 0.90)
			d.cost         = 75
			d.slow_amount  = 0.5
			d.slow_duration = 2.5
		Type.BOMB:
			d.tower_name   = "Bomb"
			d.archetype    = "AoE"
			d.damage       = 55.0
			d.range_px     = 140.0
			d.fire_rate    = 0.4
			d.color        = Color(0.90, 0.45, 0.10)
			d.cost         = 120
			d.aoe_radius   = 90.0
	return d
