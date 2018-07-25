#include "../game_state.h"
#include "../game_rules.h"
#include "../build_units_action.h"
#include "../choose_tech_action.h"
#include "../colour.h"
#include "../json.h"
#include "catch.hpp"

using json = nlohmann::json;

TEST_CASE("GameState") {
  GameRules rules("rules.json");
  GameState game(rules, 2);

  REQUIRE(game.perform_action(0, ChooseTechAction(RED)));
  REQUIRE(!game.perform_action(0, ChooseTechAction(RED)));
  REQUIRE(!game.perform_action(1, ChooseTechAction(BLACK)));
  REQUIRE(game.perform_action(1, ChooseTechAction(GREEN)));
  REQUIRE(!game.perform_action(0, BuildUnitsAction(std::vector<std::string>(
              { "grunt", "turret" }
            ))));
  REQUIRE(game.perform_action(0, BuildUnitsAction(std::vector<std::string>(
              { "grunt", "grunt" }
            ))));
  REQUIRE(game.perform_action(1, BuildUnitsAction(std::vector<std::string>(
              { "turret", "turret" }
            ))));

  while (game.get_winners().size() == 0) {
    REQUIRE(game.perform_action(0, ChooseTechAction(BLUE)));
    REQUIRE(game.perform_action(1, ChooseTechAction(BLUE)));
    REQUIRE(game.perform_action(0, BuildUnitsAction(std::vector<std::string>({}))));
    REQUIRE(game.perform_action(1, BuildUnitsAction(std::vector<std::string>({}))));
  }
}
