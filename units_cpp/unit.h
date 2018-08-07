#pragma once
#include "unit_kind.h"
#include "json.h"

using json = nlohmann::json;

class Unit {
 public:
  Unit();
  Unit(const UnitKind &kind);
  Unit(const Unit &unit);

  friend void to_json(json &j, const Unit &unit);
  friend void from_json(const json &j, Unit &unit);

  const UnitKind *kind;
  int health;
  int shields;
  int build_time; // Time remaining
};
