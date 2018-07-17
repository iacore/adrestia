#include "../player.h"
#include "../resources.h"
#include "catch.hpp"

#include <iostream>

TEST_CASE("Player") {
  GameRules rules("rules.json");
  Player p(rules);

  REQUIRE(p.units.size() == rules.get_starting_units().size());
  REQUIRE(p.alive);
  REQUIRE(p.production == Resources());
  REQUIRE(p.resources == Resources());
  REQUIRE(p.build_order.size() == 0);

  SECTION("executing build saves it in build order, builds units") {
    p.execute_build({ &rules.get_unit_kind("turret"), &rules.get_unit_kind("grunt") });
    REQUIRE(p.units.size() == rules.get_starting_units().size() + 2);
    REQUIRE(p.build_order.size() == 1);
    REQUIRE(p.build_order[0]->size() == 2);
  }

  SECTION("begin_turn increases resources by production") {
    p.production = Resources(10, 4, 2, 1);
    p.begin_turn();
    REQUIRE(p.resources == p.production);
    p.begin_turn();
    REQUIRE(p.resources == Resources(20, 8, 4, 2));
  }
}
