extends Reference

class AttackDetails:
  var player
  var unit_id
  var attack_index
  var target_player
  var target_unit_id
  var target_square_index

  func _init(player, unit_id, attack_index, target_player, target_unit_id, target_square_index):
    self.player = player
    self.unit_id = unit_id
    self.attack_index = attack_index
    self.target_player = target_player
    self.target_unit_id = target_unit_id
    self.target_square_index = target_square_index

# Array of tuples [player, unit_id, attack_index, target_player, target_unit_id, target_square_in_unit] for each player in the game
var attacks = []

func add_attack(player, unit_id, attack_index, target_player, target_unit_id, target_square_index):
  attacks.append(AttackDetails.new(player, unit_id, attack_index, target_player, target_unit_id, target_square_index))
