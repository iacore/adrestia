#include "../player.h"
#include "../resources.h"
#include "catch.hpp"

TEST_CASE("Player") {
  GameRules rules("rules.json");
  Player p(rules);

  REQUIRE(p.units.size() == rules.get_starting_units().size());
  REQUIRE(p.alive);
  REQUIRE(p.production == Resources());
  REQUIRE(p.resources == Resources());
}
