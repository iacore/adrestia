#include "battle.h"
#include "player_view.h"
#include "player.h"

Battle::Battle() {}

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
        for (int k = 0; k < unit.kind->get_width(); k++) {
          targets.push_back(std::make_pair(j, unit_id));
        }
      }
    }
    for (auto &&[unit_id, unit] : player.units) {
      if (unit.build_time > 0) continue;
      const auto &unit_attacks = unit.kind->get_attack();
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

void from_json(const json &j, Battle &battle) {
  for (auto &p : j["players"]) {
    battle.players.push_back(p);
  }
  for (auto &a : j["attacks"]) {
    battle.attacks.push_back(Attack{ a[0], a[1], a[2], a[3], a[4] });
  }
}
