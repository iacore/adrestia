#include "player.h"

Player::Player(const GameRules &rules) : alive(true) {
  std::vector<UnitKind*> starting_units = rules.get_starting_units();
  for (auto it = starting_units.begin(); it != starting_units.end(); it++) {
    units.push_back(Unit(**it));
  }
}
