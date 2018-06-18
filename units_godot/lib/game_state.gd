extends Reference

const Resources = preload("res://lib/resources.gd")
const Player = preload("res://lib/player.gd")
const Action = preload("res://lib/action.gd")
const Unit = preload("res://lib/unit.gd")
const BattleResult = preload("res://lib/battle_result.gd")

var unit_kinds
var players = []
var turn = 0

func _init(unit_kinds, num_players):
  self.unit_kinds = unit_kinds
  for i in range(num_players):
    var player = Player.new()
    player.add_unit(Unit.new(unit_kinds['general']))
    for j in range(5):
      player.add_unit(Unit.new(unit_kinds['wall']))
    players.append(player)

func start_game():
  for player in players:
    player.resources = Resources.empty()
  advance_turn()

func advance_turn():
  for player in players:
    player.resources.add(player.resource_gain)

# Returns whether the action was legal
func perform_action(action):
  if action.player < 0 || action.player >= players.size():
    return false

  if action.type == Action.CHOOSE_RESOURCES:
    if players[action.player].resource_gain.total() == 0 && action.resources.total() == 7:
      players[action.player].resource_gain = action.resources

      var should_start_game = true
      for player in players:
        if player.resource_gain.total() == 0:
          should_start_game = false
          break
      if should_start_game:
        start_game()

      return true
    return false

  elif action.type == Action.BUILD_UNIT:
    if action.kind.cost && players[action.player].resources.subsumes(action.kind.cost):
      players[action.player].add_unit(Unit.new(action.kind))
      players[action.player].resources.subtract(action.kind.cost)
      return true
    return false

func is_game_over():
  for player in players:
    if !player.units.has(0):
      return true
  return false

# Simulates the battle, advances the turn if the game is not over, and returns
# a BattleResult.
func simulate_battle():
  # TODO: charles: BattleResult should also have copy of unit states before battle
  var result = BattleResult.new()

  if is_game_over():
    return result

  # Generate attacks
  for player in range(players.size()):
    var targets = []
    var total_width = 0
    for other in range(players.size()):
      if other != player:
        for u in players[other].units:
          var width = players[other].units[u].kind.width
          targets.append([width, other, u])
          total_width += width
    for a in players[player].units:
      var attacker = players[player].units[a]
      for attack_index in attacker.kind.attack.size():
        var width_left = randi() % total_width
        for u in targets:
          if width_left < u[0]:
            result.add_attack(player, a, attack_index, u[1], u[2], width_left)
            break
          else:
            width_left -= u[0]

  # Apply attacks
  for attack in result.attacks:
    var damage = players[attack.player].units[attack.unit_id].kind.attack[attack.attack_index]
    players[attack.target_player].units[attack.target_unit_id].health -= damage

  # Remove dead units
  for player in players:
    for u in player.units:
      if player.units[u].health <= 0:
        player.units.erase(u)
    
  # Advance the turn if the game is not over
  if !is_game_over():
    advance_turn()

  return result 
