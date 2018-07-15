#pragma once
#include "unit_kind.h"
#include "json.h"

using json = nlohmann::json;

class Unit {
 public:
  Unit(const UnitKind &kind);
  Unit(const Unit &unit);

  friend void to_json(json &j, const UnitKind &kind);

  const UnitKind &kind;
  unsigned short health;
  unsigned short shields;
  unsigned short build_time; // Time remaining
};
