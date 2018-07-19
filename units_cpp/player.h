#pragma once
#include <map>
#include <memory>
#include <vector>
#include "game_rules.h"
#include "resources.h"
#include "unit.h"
#include "unit_kind.h"

class Player {
 public:
  Player(const GameRules &rules);

  void build_unit(const UnitKind &kind);
  void begin_turn();
  void execute_build(std::vector<const UnitKind*> builds);

  friend void to_json(json &j, const Player &player);

  std::map<int, Unit> units;
  bool alive;
  Resources production;
  Resources resources;
  std::vector<std::shared_ptr<const std::vector<const UnitKind*>>> build_order;
 private:
  int next_unit;
};
