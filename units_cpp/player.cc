#include "player.h"
#include "unit_kind.h"
#include "game_rules.h"

Player::Player(const GameRules &rules) : alive(true), next_unit(0) {
  std::vector<UnitKind*> starting_units = rules.get_starting_units();
  for (auto it = starting_units.begin(); it != starting_units.end(); it++) {
    build_unit(**it);
  }
}

void Player::build_unit(const UnitKind &kind) {
  units.emplace(next_unit, Unit(kind));
  next_unit++;
}

void Player::begin_turn() {
  resources.add(production);
}

void Player::execute_build(std::vector<const UnitKind*> builds) {
  for (auto it = builds.begin(); it != builds.end(); it++) {
    build_unit(**it);
  }
  build_order.push_back(std::shared_ptr<std::vector<const UnitKind*>>(
        new std::vector<const UnitKind*>(builds)));
}
