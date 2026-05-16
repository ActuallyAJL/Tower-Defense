extends Resource
class_name EnemyData

enum Type { BASIC, FAST, TANK, SWARM }

var type         : Type
var display_name : String
var max_hp       : float
var speed        : float
var size         : Vector2
var color        : Color
var gold_reward  : int
var armor        : float   # 0.0–1.0 flat damage reduction


static func create(t: Type) -> EnemyData:
	var d := EnemyData.new()
	d.type = t
	match t:
		Type.BASIC:
			d.display_name = "Basic"
			d.max_hp       = 100.0
			d.speed        = 80.0
			d.size         = Vector2(28.0, 28.0)
			d.color        = Color(0.85, 0.20, 0.20)
			d.gold_reward  = 10
			d.armor        = 0.0
		Type.FAST:
			d.display_name = "Fast"
			d.max_hp       = 50.0
			d.speed        = 155.0
			d.size         = Vector2(22.0, 22.0)
			d.color        = Color(0.95, 0.55, 0.10)
			d.gold_reward  = 8
			d.armor        = 0.0
		Type.TANK:
			d.display_name = "Tank"
			d.max_hp       = 400.0
			d.speed        = 38.0
			d.size         = Vector2(40.0, 40.0)
			d.color        = Color(0.38, 0.18, 0.55)
			d.gold_reward  = 25
			d.armor        = 0.30
		Type.SWARM:
			d.display_name = "Swarm"
			d.max_hp       = 25.0
			d.speed        = 125.0
			d.size         = Vector2(16.0, 16.0)
			d.color        = Color(0.60, 0.85, 0.20)
			d.gold_reward  = 5
			d.armor        = 0.0
	return d
