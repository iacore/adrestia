extends Node

const GameState = preload("res://lib/game_state.gd")
const AiGameManager = preload("res://lib/ai_game_manager.gd")
onready var units = get_node("/root/UnitKinds").units

# jim: We initialize man to a good value here so that we can
# use the Play Scene feature in Godot.
onready var man = AiGameManager.new(units) # Game manager

func new_ai_game():
  man = AiGameManager.new(units)
  get_tree().change_scene("res://scenes/resource_select.tscn")
