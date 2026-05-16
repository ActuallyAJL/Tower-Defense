extends Node

signal lives_changed(current: int)
signal gold_changed(current: int)
signal wave_changed(current: int)
signal game_over
signal game_won

const STARTING_LIVES := 20
const STARTING_GOLD  := 150

var lives: int
var gold: int
var wave: int


func _ready() -> void:
	reset()


func reset() -> void:
	lives = STARTING_LIVES
	gold  = STARTING_GOLD
	wave  = 0


func lose_life() -> void:
	lives -= 1
	lives_changed.emit(lives)
	if lives <= 0:
		game_over.emit()


func earn_gold(amount: int) -> void:
	gold += amount
	gold_changed.emit(gold)


## Returns false and does nothing if the player cannot afford the cost.
func spend_gold(amount: int) -> bool:
	if gold < amount:
		return false
	gold -= amount
	gold_changed.emit(gold)
	return true


func advance_wave() -> void:
	wave += 1
	wave_changed.emit(wave)
