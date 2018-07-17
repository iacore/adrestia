#pragma once
#include <map>
#include "player.h"

class PlayerView {
 public:
  PlayerView(const Player &player);

  std::map<unsigned short, Unit> units;
  bool alive;
  std::vector<std::shared_ptr<const std::vector<const UnitKind*>>> build_order;
};

