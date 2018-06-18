extends "game_manager.gd"

const GameState = preload("res://lib/game_state.gd")

var gs

func _init(units):
  gs = GameState.new(units, 2)

func perform_action(action):
  action.player = 0
  gs.perform_action(action)

func start_game(callback_obj, callback):
  # TODO: charles: put AI resource action here
  gs.start_game()
  callback_obj.call(callback)

func get_view():
  #TODO: charles: Return an actual view. Right now we trust the client not to
  # peek, and to know which player it is.
  return gs

func simulate_battle(callback_obj, callback):
  #TODO: charles: make AI move here
  var result = gs.simulate_battle()
  callback_obj.call(callback, result)