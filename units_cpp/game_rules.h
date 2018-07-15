#pragma once
#include <map>
#include "unit_kind.h"
#include "json.h"

using json = nlohmann::json;

class GameRules {
 public:
  GameRules();
  const UnitKind &get_unit_kind(std::string id) const;
  unsigned short get_starting_resources() const;

  friend void to_json(json &j, const GameRules &rules);
  friend void from_json(const json &j, GameRules &rules);
 private:
  std::map<std::string, UnitKind> unit_kinds;
  unsigned short starting_resources;
};
