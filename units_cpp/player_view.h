#pragma once
#include <map>
#include "player.h"

class PlayerView {
 public:
  PlayerView(const Player &player);

  std::map<unsigned short, Unit> units;
  bool alive;
};

