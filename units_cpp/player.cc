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
  for (auto it = units.begin(); it != units.end(); it++) {
    if (it->second.build_time > 0) {
      it->second.build_time -= 1;
    }
  }
}

void Player::execute_build(std::vector<const UnitKind*> builds) {
  for (auto it = builds.begin(); it != builds.end(); it++) {
    build_unit(**it);
  }
  build_order.push_back(std::shared_ptr<std::vector<const UnitKind*>>(
        new std::vector<const UnitKind*>(builds)));
}

void to_json(json &j, const Player &player) {
  j["units"] = player.units;
  j["alive"] = player.alive;
  j["production"] = player.production;
  j["resources"] = player.production;
  j["next_unit"] = player.next_unit;
  // TODO: charles: Save build_order
}
