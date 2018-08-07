#include "game_state.h"
#include <vector>
#include <cassert>
#include "action.h"
#include "player.h"
#include "player_view.h"
#include "battle.h"
#include "game_rules.h"

GameState::GameState() {}

GameState::GameState(int num_players)
    : turn(0)
    , players_ready(0) {
  for (int i = 0; i < num_players; i++) {
    players.push_back(Player());
  }
  begin_turn();
}

GameState::GameState(const GameState &game_state)
    : players(game_state.players)
    , action_log(game_state.action_log)
    , battles(game_state.battles)
    , turn(game_state.turn) {}

void to_json(json &j, const GameState &game_state) {
  j["players"] = game_state.players;
  j["action_log"] = game_state.action_log;
  for (const auto battle : game_state.battles) {
    j["battles"].push_back(*battle);
  }
  j["turn"] = game_state.turn;
  j["players_ready"] = game_state.players_ready;
}

void from_json(const json &j, GameState &game_state) {
  for (auto &player : j["players"]) {
    game_state.players.push_back(player);
  }
  for (auto &turn_actions : j["action_log"]) {
    game_state.action_log.push_back(std::vector<std::vector<Action>>(game_state.players.size()));
    int i = game_state.action_log.size() - 1;
    int j = 0;
    for (auto &player_actions : turn_actions) {
      for (auto &action : player_actions) {
        game_state.action_log[i][j].push_back(action);
      }
      j++;
    }
  }
  for (auto &battle : j["battles"]) {
    Battle *b = new Battle();
    *b = battle;
    game_state.battles.push_back(std::shared_ptr<Battle>(b));
  }
  game_state.turn = j["turn"];
  game_state.players_ready = j["players_ready"];
}

void GameState::begin_turn() {
  turn++;
  players_ready = 0;
  for (auto &player : players) {
    player.begin_turn();
  }
  action_log.push_back(std::vector<std::vector<Action>>(players.size()));
}

void GameState::execute_battle() {
  Battle *b = new Battle(players);
  battles.push_back(std::shared_ptr<Battle>(b));
  // Do all the damage from the attacks
  for (auto &atk : b->get_attacks()) {
    Unit &unit = players[atk.to_player].units.at(atk.to_unit);
    unit.shields -= atk.damage;
    if (unit.shields < 0) {
      unit.health += unit.shields;
      unit.shields = 0;
    }
  }
  // Kill dead units, restore shields for alive units
  for (auto &player : players) {
    for (auto it = player.units.begin(); it != player.units.end();) {
      if (it->second.health <= 0) {
        auto to_delete = it;
        it++;
        player.units.erase(to_delete);
      } else {
        it->second.shields = it->second.kind->get_shields();
        it++;
      }
    }
  }
  if (get_winners().size() == 0) {
    begin_turn();
  }
}

bool GameState::perform_action(int player, const Action &action) {
  if (get_winners().size() > 0) return false;
  if ((size_t)player >= players.size()) return false;
  Player &p = players[player];
  if (!p.alive) return false;
  int total_tech = p.tech.red + p.tech.green + p.tech.blue;
  if (action.get_type() == CHOOSE_TECH) {
    // Check action legality
    if (total_tech >= turn) return false;
    Colour colour = action.get_colour();
    if (colour == BLACK) return false;
    // Action is valid
    action_log[turn - 1][player].push_back(action);
    p.tech.increment(colour);
    return true;
  } else if (action.get_type() == BUILD_UNITS) {
    if (total_tech < turn) return false; // Haven't selected resources yet this turn
    if (p.build_order.size() > (size_t)turn) return false; // Already built units this turn
    if (action.get_units().size() + p.units.size() > (size_t)GameRules::get_instance().get_unit_cap()) return false;
    int total_cost = 0;
    std::vector<const UnitKind*> build_order;
    for (auto &name : action.get_units()) {
      const UnitKind &kind = GameRules::get_instance().get_unit_kind(name);
      if (kind.get_tech() == nullptr) return false;
      if (!p.tech.includes(*kind.get_tech())) return false;
      total_cost += kind.get_cost();
      build_order.push_back(&kind);
    }
    if (p.coins < total_cost) return false;
    // Action is valid
    action_log[turn - 1][player].push_back(action);
    p.execute_build(build_order);
    p.coins -= total_cost;
    players_ready++;
    // Perform additional work if all players have submitted action for this turn
    if (players_ready == (int)players.size()) {
      execute_battle();
    }
    return true;
  }
  return false;
}

void GameState::get_view(GameView &view, int player) const {
  // TODO: charles: What the hell C++?? Why do I have to do this?
  Player p(players[player]);
  view.view_player = p;
  view.players.clear();
  for (const auto &player : players) {
    view.players.push_back(PlayerView(player));
  }
  view.action_log = &action_log;
  view.battles = &battles;
}

std::vector<int> GameState::get_winners() const {
  std::vector<int> winners;
  for (size_t i = 0; i < players.size(); i++) {
    for (auto it = players[i].units.begin(); it != players[i].units.end(); it++) {
      if (it->second.kind->get_id() == "general") {
        winners.push_back(i);
      }
    }
  }
  if (winners.size() == 1) {
    return winners;
  } else if (winners.size() == 0) {
    for (size_t i = 0; i < players.size(); i++) {
      winners.push_back(i);
    }
    return winners;
  } else {
    return std::vector<int>();
  }
}

const std::vector<Player> &GameState::get_players() const {
  return players;
}

const std::vector<std::vector<std::vector<Action>>> &GameState::get_action_log() const {
  return action_log;
}

const std::vector<std::shared_ptr<Battle>> &GameState::get_battles() const {
  return battles;
}

int GameState::get_turn() const {
  return turn;
}
