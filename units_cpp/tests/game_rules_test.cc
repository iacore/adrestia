#include "../unit_kind.h"
#include "../game_rules.h"
#include "../json.h"
#include "catch.hpp"
#include <fstream>

using json = nlohmann::json;

TEST_CASE("GameRules") {
  GameRules::load_rules("rules.json");

  SECTION("get unit kind") {
    const UnitKind &kind = GameRules::get_instance().get_unit_kind("general");
    REQUIRE(kind.get_id() == "general");
  }

  SECTION("starting resources and units") {
    REQUIRE(GameRules::get_instance().get_unit_cap() == 50);
    REQUIRE(GameRules::get_instance().get_starting_units().size() == 6);
  }
}
