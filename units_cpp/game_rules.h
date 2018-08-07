#pragma once
#include <map>
#include "unit_kind.h"
#include "json.h"

using json = nlohmann::json;

class GameRules {
 public:
  GameRules(const GameRules &rules) = delete;
  void operator=(const GameRules &rules) = delete;

  static GameRules &get_instance();
  static void load_rules(std::string rules_filename);

  const UnitKind &get_unit_kind(std::string id) const;
  int get_unit_cap() const;
  const std::map<std::string, UnitKind> &get_unit_kinds() const;
  const std::vector<UnitKind*> &get_starting_units() const;

  friend void to_json(json &j, const GameRules &rules);
  friend void from_json(const json &j, GameRules &rules);
 private:
  GameRules(); // for json.h
  GameRules(std::string rules_filename);
  static GameRules *instance;

  std::map<std::string, UnitKind> unit_kinds;
  int unit_cap;
  std::vector<UnitKind*> starting_units;
};
