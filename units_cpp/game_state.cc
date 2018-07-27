#include "game_state.h"
#include <vector>
#include "action.h"
#include "build_units_action.h"
#include "choose_tech_action.h"
#include "player.h"
#include "player_view.h"

Battle::Battle(const std::vector<Player> &players) {
  for (auto &&player : players) {
    this->players.push_back(PlayerView(player));
  }
  for (size_t i = 0; i < players.size(); i++) {
    const Player &player = players[i];
    std::vector<std::pair<int, int>> targets;
    for (size_t j = 0; j < players.size(); j++) {
      if (j == i) continue;
      for (auto &&[unit_id, unit] : players[j].units) {
        for (int k = 0; k < unit.kind.get_width(); k++) {
          targets.push_back(std::make_pair(j, unit_id));
        }
      }
    }
    for (auto &&[unit_id, unit] : player.units) {
      if (unit.build_time > 0) continue;
      const auto &unit_attacks = unit.kind.get_attack();
      for (int dmg : unit_attacks) {
        int target_index = Battle::gen() % targets.size();
        attacks.push_back(Attack{
            (int)i, unit_id,
            targets[target_index].first,
            targets[target_index].second,
            dmg
        });
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
  for (const auto &player : battle.players) {
    j["players"].push_back(player);
  }
  for (const auto &it : battle.attacks) {
    j["attacks"].push_back({ it.from_player, it.from_unit, it.to_player, it.to_unit, it.damage });
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
  begin_turn();
}

// TODO: charles: Is this just the default copy constructor?
GameState::GameState(const GameState &game_state)
    : rules(game_state.rules)
    , players(game_state.players)
    , battles(game_state.battles)
    , turn(game_state.turn) {}

void to_json(json &j, const GameState &game_state) {
  for (const auto &player : game_state.players) {
    j["players"].push_back(player);
  }
  for (const auto battle : game_state.battles) {
    j["battles"].push_back(*battle);
  }
  j["turn"] = game_state.turn;
  j["players_ready"] = game_state.players_ready;
  j["stage"] = game_state.stage;
}

std::vector<int> GameState::get_winners() const {
  std::vector<int> winners;
  for (size_t i = 0; i < players.size(); i++) {
    for (auto it = players[i].units.begin(); it != players[i].units.end(); it++) {
      if (it->second.kind.get_id() == "general") {
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

void GameState::begin_turn() {
  turn++;
  players_ready = 0;
  stage = BUILDING;
  for (auto &player : players) {
    player.begin_turn();
  }
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
        it->second.shields = it->second.kind.get_shields();
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
  if ((size_t)player > players.size()) return false;
  Player &p = players[player];
  if (!p.alive) return false;
  int total_tech = p.tech.red + p.tech.green + p.tech.blue;
  if (action.get_type() == CHOOSE_TECH) {
    // Check action legality
    if (total_tech >= turn) return false;
    const ChooseTechAction *a = (ChooseTechAction*)&action;
    Colour colour = a->get_colour();
    if (colour == BLACK) return false;
    // Action is valid
    p.tech.increment(colour);
    return true;
  } else if (action.get_type() == BUILD_UNITS) {
    if (total_tech < turn) return false; // Haven't selected resources yet this turn
    if (p.build_order.size() > (size_t)turn) return false; // Already built units this turn
    const BuildUnitsAction *a = (BuildUnitsAction*)&action;
    if (a->get_units().size() + p.units.size() > (size_t)rules.get_unit_cap()) return false;
    int total_cost = 0;
    std::vector<const UnitKind*> build_order;
    for (auto it = a->get_units().begin(); it != a->get_units().end(); it++) {
      const UnitKind &kind = rules.get_unit_kind(*it);
      if (kind.get_tech() == nullptr) return false;
      if (!p.tech.includes(*kind.get_tech())) return false;
      total_cost += kind.get_cost();
      build_order.push_back(&kind);
    }
    if (p.coins < total_cost) return false;
    // Action is valid
    p.execute_build(build_order);
    p.coins -= total_cost;
    players_ready++;
    // Perform additional work if all players have submitted action for this stage
    if (players_ready == (int)players.size()) {
      execute_battle();
    }
    return true;
  }
  return false;
}
