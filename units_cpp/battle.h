#pragma once
#include <random>
#include "player_view.h"
#include "player.h"

struct Attack {
  int from_player;
  int from_unit;
  int to_player;
  int to_unit;
  int damage;
};

class Battle {
 public:
  Battle();
  Battle(const std::vector<Player> &players);
  Battle(const GameRules &rules, const json &j);
  static void set_seed(long seed);

  const std::vector<PlayerView> &get_players() const;
  const std::vector<Attack> &get_attacks() const;

  friend void to_json(json &j, const Battle &battle);
 private:
  std::vector<PlayerView> players;
  std::vector<Attack> attacks;

  static std::mt19937 gen;
};
