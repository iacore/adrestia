#include "player_view.h"
#include "player.h"

PlayerView::PlayerView(const Player &player)
    : units(player.units)
    , alive(player.alive)
    , build_order(player.build_order) {}
