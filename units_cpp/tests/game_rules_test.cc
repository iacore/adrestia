#include "../unit_kind.h"
#include "../game_rules.h"
#include "../json.h"
#include "catch.hpp"
#include <fstream>

using json = nlohmann::json;

TEST_CASE("GameRules") {
  json j;
  std::ifstream in("rules.json");
  in >> j;
  GameRules rules = j;

  SECTION("get unit kind") {
    const UnitKind &kind = rules.get_unit_kind("general");
    REQUIRE(kind.get_id() == "general");
  }
}
