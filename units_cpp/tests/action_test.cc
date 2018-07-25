#include "../tech.h"
#include "../action.h"
#include "../choose_tech_action.h"
#include "../build_units_action.h"
#include "../game_rules.h"
#include "catch.hpp"

TEST_CASE("Action") {
  SECTION("ChooseTechAction") {
    Action *a = new ChooseTechAction(GREEN);
    REQUIRE(a->get_type() == CHOOSE_TECH);
    ChooseTechAction *cra = (ChooseTechAction*)a;
    REQUIRE(cra->get_colour() == GREEN);
    delete a;
  }

  SECTION("BuildUnitsAction") {
    GameRules rules("rules.json");
    Action *a = new BuildUnitsAction(std::vector<std::string>({"turret"}));
    REQUIRE(a->get_type() == BUILD_UNITS);
    BuildUnitsAction *bua = (BuildUnitsAction*)a;
    REQUIRE(bua->get_units().size() == 1);
    REQUIRE(bua->get_units()[0] == "turret");
    delete a;
  }
}
