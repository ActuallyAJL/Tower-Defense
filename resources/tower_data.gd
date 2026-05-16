extends Resource
class_name TowerData

enum Type { BASIC, SNIPER, SLOW, BOMB }

var type         : Type
var display_name : String
var damage       : float
var range_px     : float
var fire_rate    : float   # shots per second
var color        : Color
var cost         : int
var aoe_radius   : float   # 0 = single target
var slow_amount  : float   # speed multiplier applied to hit enemy (e.g. 0.5 = half speed)
var slow_duration: float   # seconds the slow lasts
var pierce_armor : bool    # ignores enemy armor stat


static func create(t: Type) -> TowerData:
	var d := TowerData.new()
	d.type         = t
	d.aoe_radius   = 0.0
	d.slow_amount  = 0.0
	d.slow_duration= 0.0
	d.pierce_armor = false
	match t:
		Type.BASIC:
			d.display_name = "Basic"
			d.damage       = 25.0
			d.range_px     = 160.0
			d.fire_rate    = 1.0
			d.color        = Color(0.30, 0.50, 0.85)
			d.cost         = 50
		Type.SNIPER:
			d.display_name = "Sniper"
			d.damage       = 100.0
			d.range_px     = 280.0
			d.fire_rate    = 0.5
			d.color        = Color(0.15, 0.25, 0.60)
			d.cost         = 100
			d.pierce_armor = true
		Type.SLOW:
			d.display_name = "Slow"
			d.damage       = 10.0
			d.range_px     = 130.0
			d.fire_rate    = 0.8
			d.color        = Color(0.20, 0.80, 0.90)
			d.cost         = 75
			d.slow_amount  = 0.5
			d.slow_duration= 2.5
		Type.BOMB:
			d.display_name = "Bomb"
			d.damage       = 55.0
			d.range_px     = 140.0
			d.fire_rate    = 0.4
			d.color        = Color(0.90, 0.45, 0.10)
			d.cost         = 120
			d.aoe_radius   = 90.0
	return d
