#pragma once
#include <vector>
#include "resources.h"
#include "unit.h"
#include "game_rules.h"

class Player {
 public:
  Player(const GameRules &rules);
   
  std::vector<Unit> units;
  bool alive;
  Resources production;
  Resources resources;
};
