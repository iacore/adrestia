#include "game_rules.h"
#include <iostream>

GameRules::GameRules() {}

void to_json(json &j, const GameRules &rules) {
  for (auto it = rules.unit_kinds.begin(); it != rules.unit_kinds.end(); it++) {
    j["unit_kinds"].push_back(it->second);
  }
  j["starting_resources"] = rules.starting_resources;
}

void from_json(const json &j, GameRules &rules) {
  for (auto it = j["unit_kinds"].begin(), end = j["unit_kinds"].end(); it != end; it++) {
    rules.unit_kinds.emplace((*it)["id"].get<std::string>(), *it);
  }
  rules.starting_resources = 7;
}

const UnitKind &GameRules::get_unit_kind(std::string id) const {
  return unit_kinds.at(id);
}

unsigned short GameRules::get_starting_resources() const {
  return starting_resources;
}
