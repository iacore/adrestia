#pragma once
#include <map>
#include "game_rules.h"
#include "resources.h"
#include "unit.h"
#include "unit_kind.h"

class Player {
 public:
  Player(const GameRules &rules);

  void build_unit(const UnitKind &kind);
  void begin_turn();

  std::map<unsigned short, Unit> units;
  bool alive;
  Resources production;
  Resources resources;
 private:
  unsigned short next_unit;
};
