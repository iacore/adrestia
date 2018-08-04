#pragma once
#include <vector>
#include <memory>
#include <random>
#include "game_rules.h"
#include "action.h"
#include "player.h"
#include "player_view.h"
#include "json.h"

using json = nlohmann::json;

struct Attack {
  int from_player;
  int from_unit;
  int to_player;
  int to_unit;
  int damage;
};

class Battle {
 public:
  Battle(const std::vector<Player> &players);
  static void set_seed(long seed);

  const std::vector<PlayerView> &get_players() const;
  const std::vector<Attack> &get_attacks() const;

  friend void to_json(json &j, const Battle &battle);
 private:
  std::vector<PlayerView> players;
  std::vector<Attack> attacks;

  static std::mt19937 gen;
};

class GameState {
 public:
  GameState(const GameRules &rules, int num_players);
  GameState(const GameState &game_state);
  bool perform_action(int player, const Action &action);
  // const GameView &get_view(int player);
  std::vector<int> get_winners() const; // Empty list indicates that game is still in progress
  int get_turn() const;
  const std::vector<Player> &get_players() const;
  const std::vector<std::vector<std::vector<Action>>> &get_action_log() const;
  const std::vector<std::shared_ptr<Battle>> &get_battles() const;

  friend void to_json(json &j, const GameState &game_state);
 private:
  const GameRules &rules;
  std::vector<Player> players;
  std::vector<std::vector<std::vector<Action>>> action_log;
  std::vector<std::shared_ptr<Battle>> battles;
  int turn;
  int players_ready;

  void begin_turn();
  void execute_battle(); // Executes the battle and advances the turn
};
