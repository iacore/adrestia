extends Node

# TODO: charles: Replace global.gd with a game state.

const Resources = preload("res://lib/resources.gd")
const Player = preload("res://lib/player.gd")

var players

func _ready():
  players = [Player.new(), Player.new()]

func start_game():
  for player in players:
    player.resources = Resources.empty()
    player.resources.add(player.resource_gain)

func advance_turn():
  for player in players:
    player.resources.add(player.resource_gain)