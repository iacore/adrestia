#include "../unit_kind.h"
#include "../json.h"
#include "catch.hpp"

using json = nlohmann::json;

TEST_CASE("UnitKind") {
  SECTION("stats for General") {
    json general_json = R"(
    {
      "name": "General",
      "colour": "BLACK",
      "health": 5,
      "width": 1,
      "attack": [1],
      "cost": null,
      "image": "commander.png",
      "tiles": [0, 0],
      "label": "G"
    })"_json;
    UnitKind general = general_json;
    REQUIRE(json(general) == general_json);

    REQUIRE(general.get_name() == "General");
    REQUIRE(general.get_colour() == BLACK);
    REQUIRE(general.get_health() == 5);
    REQUIRE(general.get_shields() == 0);
    REQUIRE(general.get_width() == 1);
    REQUIRE(general.get_build_time() == 0);
    REQUIRE(general.get_attack().size() == 1);
    REQUIRE(general.get_attack()[0] == 1);
    REQUIRE(general.get_cost() == nullptr);
    REQUIRE(general.get_font() == nullptr);
    REQUIRE(general.get_image() == "commander.png");
    REQUIRE(general.get_tiles().size() == 2);
    REQUIRE(general.get_label() == 'G');
  }

  SECTION("stats for normal unit") {
    UnitKind kind = R"(
    {
      "name": "Super Turret",
      "colour": "GREEN",
      "health": 4,
      "shields": 2,
      "width": 3,
      "build_time": 1,
      "attack": [3, 1],
      "cost": {"green": 3, "blue": 3},
      "image": "superturret.png",
      "tiles": [0, 0, 0, 1, 0, 2],
      "label": "S"
    })"_json;

    REQUIRE(kind.get_name() == "Super Turret");
    REQUIRE(kind.get_colour() == GREEN);
    REQUIRE(kind.get_health() == 4);
    REQUIRE(kind.get_shields() == 2);
    REQUIRE(kind.get_width() == 3);
    REQUIRE(kind.get_build_time() == 1);
    REQUIRE(kind.get_attack().size() == 2);
    REQUIRE(kind.get_attack()[0] == 3);
    REQUIRE(kind.get_attack()[1] == 1);
    REQUIRE(*kind.get_cost() == Resources(0, 3, 3));
    REQUIRE(kind.get_font() == nullptr);
    REQUIRE(kind.get_image() == "superturret.png");
    REQUIRE(kind.get_tiles().size() == 6);
    REQUIRE(kind.get_label() == 'S');
  }
}
