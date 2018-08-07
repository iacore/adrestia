#pragma once
#include <map>
#include <memory>
#include <vector>
#include "game_rules.h"
#include "tech.h"
#include "unit.h"
#include "unit_kind.h"

class Player {
 public:
  Player();
  Player(const Player &player);
  Player &operator=(Player &player);

  void build_unit(const UnitKind &kind);
  void begin_turn();
  void execute_build(std::vector<const UnitKind*> builds);

  friend void to_json(json &j, const Player &player);
  friend void from_json(const json &j, Player &player);

  std::map<int, Unit> units;
  bool alive;
  Tech tech;
  std::vector<std::shared_ptr<const std::vector<const UnitKind*>>> build_order;
  int coins;
 private:
  int next_unit;
};
