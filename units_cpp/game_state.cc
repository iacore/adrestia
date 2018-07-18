#include "game_state.h"
#include <vector>
#include "player.h"
#include "player_view.h"

Battle::Battle(const std::vector<Player> &players, long seed) {
  for (auto it = players.begin(); it != players.end(); it++) {
    this->players.push_back(PlayerView(*it));
  }
  // TODO: charles: create all the attacks
}

const std::vector<PlayerView> &Battle::get_players() const {
  return players;
}

const std::vector<Attack> &Battle::get_attacks() const {
  return attacks;
}

GameState::GameState(const GameRules &rules, unsigned short num_players)
    : rules(rules)
    , turn(0) {
  for (unsigned short i = 0; i < num_players; i++) {
    players.push_back(Player(rules));
  }
}

// TODO: charles: Is this just the default copy constructor?
GameState::GameState(const GameState &game_state)
    : rules(game_state.rules)
    , players(game_state.players)
    , battles(game_state.battles)
    , turn(game_state.turn) {}

bool GameState::perform_action(unsigned short player, const Action &action) {
}
