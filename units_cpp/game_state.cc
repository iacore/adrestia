#include "game_state.h"
#include <vector>
#include "action.h"
#include "build_units_action.h"
#include "choose_resources_action.h"
#include "player.h"
#include "player_view.h"

Battle::Battle(const std::vector<Player> &players) {
  for (auto it = players.begin(); it != players.end(); it++) {
    this->players.push_back(PlayerView(*it));
  }
  for (int i = 0; i < players.size(); i++) {
    const Player &player = players[i];
    std::vector<std::pair<int, int>> targets;
    for (int j = 0; j < players.size(); j++) {
      if (j == i) continue;
      for (auto it = players[j].units.begin(); it != players[j].units.end(); it++) {
        for (int k = 0; k < it->second.kind.get_width(); k++) {
          targets.push_back(std::make_pair(j, it->first));
        }
      }
    }
    for (auto it = player.units.begin(); it != player.units.end(); it++) {
      const auto &unit_attacks = it->second.kind.get_attack();
      for (auto dmg = unit_attacks.begin(); dmg != unit_attacks.end(); dmg++) {
        int target_index = Battle::gen() % targets.size();
        attacks.push_back(Attack{ i, it->first, targets[target_index].first, targets[target_index].second, *dmg });
      }
    }
  }
}

std::mt19937 Battle::gen;

void Battle::set_seed(long seed) {
  Battle::gen.seed(seed);
}

const std::vector<PlayerView> &Battle::get_players() const {
  return players;
}

const std::vector<Attack> &Battle::get_attacks() const {
  return attacks;
}

void to_json(json &j, const Battle &battle) {
  for (auto it = battle.players.begin(); it != battle.players.end(); it++) {
    j["players"].push_back(*it);
  }
  for (auto it = battle.attacks.begin(); it != battle.attacks.end(); it++) {
    j["attacks"].push_back({ it->from_player, it->from_unit, it->to_player, it->to_unit, it->damage });
  }
}

GameState::GameState(const GameRules &rules, int num_players)
    : rules(rules)
    , turn(0)
    , players_ready(0)
    , stage(CHOOSING_RESOURCES) {
  for (int i = 0; i < num_players; i++) {
    players.push_back(Player(rules));
  }
}

// TODO: charles: Is this just the default copy constructor?
GameState::GameState(const GameState &game_state)
    : rules(game_state.rules)
    , players(game_state.players)
    , battles(game_state.battles)
    , turn(game_state.turn) {}

void to_json(json &j, const GameState &game_state) {
  for (auto it = game_state.players.begin(); it != game_state.players.end(); it++) {
    j["players"].push_back(*it);
  }
  for (auto it = game_state.battles.begin(); it != game_state.battles.end(); it++) {
    j["battles"].push_back(**it);
  }
  j["turn"] = game_state.turn;
  j["players_ready"] = game_state.players_ready;
  j["stage"] = game_state.stage;
}

std::vector<int> GameState::get_winners() const {
  // TODO: charles: Implement this
  return std::vector<int>();
}

void GameState::begin_building() {
  players_ready = 0;
  stage = BUILDING;
  for (auto it = players.begin(); it != players.end(); it++) {
    it->begin_turn();
  }
}

void GameState::execute_battle() {
  Battle *b = new Battle(players);
  battles.push_back(std::shared_ptr<Battle>(b));
  // Do all the damage from the attacks
  for (auto it = b->get_attacks().begin(); it != b->get_attacks().end(); it++) {
    Unit &unit = players[it->to_player].units.at(it->to_unit);
    unit.shields -= it->damage;
    if (unit.shields < 0) {
      unit.health += unit.shields;
      unit.shields = 0;
    }
  }
  // Kill dead units
  for (auto player = players.begin(); player != players.end(); player++) {
    for (auto it = player->units.begin(); it != player->units.end();) {
      if (it->second.health <= 0) {
        auto to_delete = it;
        it++;
        player->units.erase(to_delete);
      } else {
        it->second.shields = it->second.kind.get_shields();
        it++;
      }
    }
  }
  players_ready = 0;
  if (get_winners().size() == 0) {
    turn++;
    for (auto it = players.begin(); it != players.end(); it++) {
      it->begin_turn();
    }
  }
}

bool GameState::perform_action(int player, const Action &action) {
  if (get_winners().size() > 0) return false;
  if (player > players.size()) return false;
  if (!players[player].alive) return false;
  if (action.get_type() == CHOOSE_RESOURCES) {
    // Check action legality
    if (stage != CHOOSING_RESOURCES) return false;
    if (!(players[player].production == Resources())) return false;
    const ChooseResourcesAction *a = (ChooseResourcesAction*)&action;
    const Resources &r = a->get_resources();
    if (r.coins != 0) return false;
    if (r.red + r.green + r.blue != rules.get_starting_resources()) return false;
    // Action is valid
    players[player].production = r;
    players_ready++;
    // Perform additional work if all players have submitted action for this stage
    if (players_ready == players.size()) {
      begin_building();
    }
    return true;
  } else if (action.get_type() == BUILD_UNITS) {
    if (stage != BUILDING) return false;
    if (players[player].build_order.size() > turn) return false; // Already build units this turn
    const BuildUnitsAction *a = (BuildUnitsAction*)&action;
    Resources total_cost;
    for (auto it = a->get_units().begin(); it != a->get_units().end(); it++) {
      if ((*it)->get_cost() == nullptr) return false;
      // TODO: also check for unit availability
      total_cost.add(*(*it)->get_cost());
    }
    if (!players[player].resources.includes(total_cost)) return false;
    // Action is valid
    players[player].execute_build(a->get_units());
    players[player].resources.subtract(total_cost);
    players_ready++;
    // Perform additional work if all players have submitted action for this stage
    if (players_ready == players.size()) {
      execute_battle();
    }
    return true;
  }
  return false;
}
