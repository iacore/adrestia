#include "../resources.h"
#include "../action.h"
#include "../choose_resources_action.h"
#include "../build_units_action.h"
#include "../game_rules.h"
#include "catch.hpp"

TEST_CASE("Action") {
  SECTION("ChooseResourcesAction") {
    Action *a = new ChooseResourcesAction(Resources(1, 2, 3, 4));
    REQUIRE(a->get_type() == CHOOSE_RESOURCES);
    ChooseResourcesAction *cra = (ChooseResourcesAction*)a;
    REQUIRE(cra->get_resources() == Resources(1, 2, 3, 4));
    delete a;
  }

  SECTION("BuildUnitsAction") {
    GameRules rules("rules.json");
    Action *a = new BuildUnitsAction(std::vector<const UnitKind*>({&rules.get_unit_kind("turret")}));
    REQUIRE(a->get_type() == BUILD_UNITS);
    BuildUnitsAction *bua = (BuildUnitsAction*)a;
    REQUIRE(bua->get_units().size() == 1);
    REQUIRE(bua->get_units()[0]->get_id() == "turret");
    delete a;
  }
}
