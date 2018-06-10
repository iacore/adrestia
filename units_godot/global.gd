extends Node

var lib = preload("res://lib.gd")	

var players

func _ready():
	players = [lib.Player.new(), lib.Player.new()]

func start_game():
	for player in players:
		player.resources = lib.Resources.empty()
		player.resources.add(player.resource_gain)

func advance_turn():
	for player in players:
		player.resources.add(player.resource_gain)