#include <iostream>
#include "resources.h"
#include "unit_kind.h"
#include "json.h"

using json = nlohmann::json;

int main() {
  std::cout << "=== Adrestia C++ Test Suite ===" << std::endl;
  Resources r1(0,1,2,3);
  Resources r2(0,2,3,1);
  std::cout << "r1:       " << r1 << std::endl;
  std::cout << "r2:       " << r2 << std::endl;
  std::cout << "r1 + r2:  " << (r1 + r2) << std::endl;
  std::cout << "r1 <= r2: " << (r1 <= r2) << std::endl;
  std::cout << "json(r1).get<Resources>(): " << json(r1).get<Resources>() << std::endl;
  // Unit Kind
  UnitKind general = R"(
  {
    "name": "General",
    "colour": "BLACK",
    "health": 5,
    "width": 1,
    "attack": [1],
    "cost": {"red": 5},
    "image": "commander.png",
    "tiles": [0, 0],
    "label": "G"
  })"_json;
  std::cout << json(general) << std::endl;
  return 0;
}
