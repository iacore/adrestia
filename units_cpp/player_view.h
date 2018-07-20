#pragma once
#include <map>
#include "player.h"

class PlayerView {
 public:
  PlayerView(const Player &player);

  friend void to_json(json &j, const PlayerView &view);

  std::map<int, Unit> units;
  bool alive;
  std::vector<std::shared_ptr<const std::vector<const UnitKind*>>> build_order;
};

