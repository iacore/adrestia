#pragma once
#include <vector>
#include <memory>
#include "game_rules.h"
#include "action.h"
#include "choose_resources_action.h"
#include "build_units_action.h"
#include "player.h"
#include "player_view.h"
#include "json.h"

using json = nlohmann::json;

struct Attack {
  unsigned short from_player;
  unsigned short from_unit;
  unsigned short to_player;
  unsigned short to_unit;
}

class Battle {
 public:
  // Battle(const std::vector<Player> &players);
  Battle(const std::vector<Player> &players, long seed);
  Battle(const Battle &battle) = 0;

  const std::vector<PlayerView> &get_players() const;
  const std::vector<Attack> &get_attacks() const;
 private:
  std::vector<PlayerView> players;
  std::vector<Attack> attacks;
};

class GameState {
 public:
  GameState(const GameRules &rules, unsigned short num_players);
  GameState(const GameState &game_state);
  bool perform_action(unsigned short player, const Action &action);
  const GameView &get_view(unsigned short player);
  std::vector<unsigned short> get_winners() const; // Empty list indicates that game is still in progress

  friend void to_json(json &j, const GameState &game_state);
  friend void from_json(const json &j, GameState &game_state);
 private:
  const GameRules &rules;
  std::vector<Player> players;
  std::vector<std::shared_ptr<Battle>> battles;
  unsigned int turn;
};
