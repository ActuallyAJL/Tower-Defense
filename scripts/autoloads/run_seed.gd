extends Node

var seed: int = 0
var rng: RandomNumberGenerator = RandomNumberGenerator.new()


func start_run(s: int) -> void:
	seed = s
	rng.seed = s
