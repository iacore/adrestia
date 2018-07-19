#include "player_view.h"
#include "player.h"

PlayerView::PlayerView(const Player &player)
    : units(player.units)
    , alive(player.alive)
    , build_order(player.build_order) {}

void to_json(json &j, const PlayerView &view) {
  j["units"] = view.units;
  j["alive"] = view.alive;
  // TODO: charles: Save build_order
}
