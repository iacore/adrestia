extends Node

const GameState = preload("res://lib/game_state.gd")
const Player = preload("res://lib/player.gd")
onready var units = get_node("/root/UnitKinds").units

onready var gs = GameState.new(units, 2)
