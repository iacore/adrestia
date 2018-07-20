#include "../game_state.h"
#include "../game_rules.h"
#include "../build_units_action.h"
#include "../choose_resources_action.h"
#include "../resources.h"
#include "../json.h"
#include "catch.hpp"

using json = nlohmann::json;

TEST_CASE("GameState") {
  GameRules rules("rules.json");
  GameState game(rules, 2);

  REQUIRE(game.perform_action(0, ChooseResourcesAction(Resources(0, 4, 2, 1))));
  REQUIRE(!game.perform_action(0, ChooseResourcesAction(Resources(0, 4, 2, 1))));
  REQUIRE(game.perform_action(1, ChooseResourcesAction(Resources(0, 4, 2, 1))));
  REQUIRE(game.perform_action(0, BuildUnitsAction(std::vector<std::string>(
              { "grunt", "grunt", "turret" }
            ))));
  REQUIRE(game.perform_action(1, BuildUnitsAction(std::vector<std::string>({}))));

  while (game.get_winners().size() == 0) {
    REQUIRE(game.perform_action(0, BuildUnitsAction(std::vector<std::string>({}))));
    REQUIRE(game.perform_action(1, BuildUnitsAction(std::vector<std::string>({}))));
  }
}
