#include "player_view.h"
#include "player.h"

PlayerView::PlayerView() {}

PlayerView::PlayerView(const Player &player)
    : units(player.units)
    , alive(player.alive)
    , build_order(player.build_order) {}

void to_json(json &j, const PlayerView &view) {
  for (auto &&[unit_id, unit] : view.units) {
    j["units"][std::to_string(unit_id)] = unit;
  }
  j["alive"] = view.alive;
  // TODO: charles: Save build_order
}

void from_json(const json &j, PlayerView &view) {
  for (auto it = j["units"].begin(); it != j["units"].end(); it++) {
    view.units.emplace(std::stoi(it.key()), it.value());
  }
  view.alive = j["alive"];
}
