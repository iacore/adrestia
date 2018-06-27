extends "game_manager.gd"

const GameState = preload("res://lib/game_state.gd")
const ChooseResources = preload("res://lib/actions/choose_resources.gd")
const BuildUnit = preload("res://lib/actions/build_unit.gd")
const Resources = preload("res://lib/resources.gd")

var gs
var units

func _init(units):
  self.units = units
  gs = GameState.new(units, 2)

func perform_action(action):
  action.player = 0
  gs.perform_action(action)

func start_game(callback_obj, callback):
  # AI resource selection
  randomize()
  var x = randi() % 4
  var y = randi() % 4
  var r = 1 + min(x, y)
  var g = 1 + abs(x - y)
  var b = 7 - r - g
  gs.perform_action(ChooseResources.new(1, Resources.new(r, g, b)))
  # Start the game
  gs.start_game()
  callback_obj.call(callback)

func get_view():
  # TODO: charles: Return an actual view. Right now we trust the client not to
  # peek, and to know which player it is.
  return gs

func end_turn(callback_obj, callback):
  # AI move
  randomize()
  var resources = get_view().players[1].resources
  for i in range(100):
    if resources.total() <= 1:
      break
    var u = randi() % units.size()
    var kind = units[units.keys()[u]]
    if kind.cost != null && resources.subsumes(kind.cost):
      gs.perform_action(BuildUnit.new(1, kind))
  callback_obj.call(callback)

func simulate_battle(callback_obj, callback):
  # Actually run battle
  var result = gs.simulate_battle()
  callback_obj.call(callback, result)
