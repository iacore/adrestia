#include "../game_state.h"
#include "../game_rules.h"
#include "../colour.h"
#include "../json.h"
#include "catch.hpp"

using json = nlohmann::json;

TEST_CASE("GameState") {
  GameRules rules("rules.json");
  GameState game(rules, 2);

  REQUIRE(game.perform_action(0, Action(RED)));
  REQUIRE(!game.perform_action(0, Action(BLUE)));
  REQUIRE(!game.perform_action(1, Action(BLACK)));
  REQUIRE(game.perform_action(1, Action(GREEN)));
  REQUIRE(!game.perform_action(0, Action(std::vector<std::string>({ "grunt", "turret" }))));
  REQUIRE(game.perform_action(0, Action(std::vector<std::string>({ "grunt", "grunt" }))));
  REQUIRE(game.perform_action(1, Action(std::vector<std::string>({ "turret", "turret" }))));

  while (game.get_winners().size() == 0) {
    REQUIRE(game.perform_action(0, Action(BLUE)));
    REQUIRE(game.perform_action(1, Action(BLUE)));
    REQUIRE(game.perform_action(0, Action(std::vector<std::string>({}))));
    REQUIRE(game.perform_action(1, Action(std::vector<std::string>({}))));
  }

  REQUIRE(game.get_action_log().size() == game.get_turn());
  REQUIRE(game.get_action_log()[0][0][0] == Action(RED));
  REQUIRE(game.get_action_log()[0][0][1] == Action(std::vector<std::string>({"grunt", "grunt"})));
}
