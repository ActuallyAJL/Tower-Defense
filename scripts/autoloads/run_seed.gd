extends Node

## RunSeed — global singleton for the current run.
## Holds the seeded RNG and all procedurally generated run data.
## Call start_run() once (from main.gd _ready()) before accessing any other fields.

var seed_value     : int = 0
var rng            : RandomNumberGenerator = RandomNumberGenerator.new()

## Generated once per run by start_run().
var active_elements: Array[ElementData] = []
var tower_roster   : Array[TowerData]   = []
var enemy_types    : Array[EnemyData]   = []
var waves          : Array              = []   # Array of wave Dicts; see WaveGen for format


func start_run(s: int) -> void:
	seed_value  = s
	rng.seed    = s

	# Run all generators in dependency order.
	# Each generator consumes RNG state deterministically, so the same seed
	# always produces the same run regardless of call order or platform.
	active_elements = ElementGen.generate(rng)
	tower_roster    = TowerGen.generate(rng, active_elements)
	enemy_types     = EnemyGen.generate(rng, active_elements)
	waves           = WaveGen.generate(rng, enemy_types)
