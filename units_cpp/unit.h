#pragma once
#include "unit_kind.h"
#include "json.h"

using json = nlohmann::json;

class Unit {
 public:
  Unit(const UnitKind &kind);

  friend void to_json(json &j, const Unit &unit);

  const UnitKind &kind;
  int health;
  int shields;
  int build_time; // Time remaining
};
