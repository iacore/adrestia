#include "../resources.h"
#include "../json.h"
#include "catch.hpp"

using json = nlohmann::json;

TEST_CASE("Resources") {
  Resources r1(0,1,2,3);
  Resources r2(1,2,3,1);
  Resources r3(2,1,2,4);

  SECTION("default value") {
    REQUIRE(Resources() == Resources(0, 0, 0, 0));
  }

  SECTION("equality") {
    REQUIRE(r1 == r1);
    REQUIRE(!(r1 == r2));
  }
  
  SECTION("addition and includes") {
    REQUIRE((r1 + r2 == Resources(1, 3, 5, 4)));
    REQUIRE(r1 <= r1);
    REQUIRE(!(r1 <= r2));
    REQUIRE(!(r2 <= r1));
    REQUIRE(r1 <= r3);
    REQUIRE(!(r3 <= r1));
  }

  SECTION("json conversion") {
    Resources r4 = Resources(2, 3, 0, 1);
    REQUIRE(json(r1).get<Resources>() == r1);
    REQUIRE(json(r1) == R"({"blue":3,"green":2,"red":1})"_json);
    REQUIRE(json(r4).get<Resources>() == r4);
    REQUIRE(json(r4) == R"({"blue":1,"coins":2,"red":3})"_json);
  }
}
