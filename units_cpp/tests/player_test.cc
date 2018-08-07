#include "../player.h"
#include "../tech.h"
#include "catch.hpp"

#include <iostream>

TEST_CASE("Player") {
  GameRules::load_rules("rules.json");
  Player p;

  REQUIRE(p.units.size() == GameRules::get_instance().get_starting_units().size());
  REQUIRE(p.alive);
  REQUIRE(p.tech == Tech());
  REQUIRE(p.coins == 0);
  REQUIRE(p.build_order.size() == 0);

  SECTION("executing build saves it in build order, builds units") {
    p.execute_build({ &GameRules::get_instance().get_unit_kind("turret"), &GameRules::get_instance().get_unit_kind("grunt") });
    REQUIRE(p.units.size() == GameRules::get_instance().get_starting_units().size() + 2);
    REQUIRE(p.build_order.size() == 1);
    REQUIRE(p.build_order[0]->size() == 2);
  }

  SECTION("begin_turn increases coins by total font") {
    p.begin_turn();
    REQUIRE(p.coins == 5);
    p.execute_build({ &GameRules::get_instance().get_unit_kind("worker") });
    p.begin_turn();
    REQUIRE(p.coins == 11);
  }
}
