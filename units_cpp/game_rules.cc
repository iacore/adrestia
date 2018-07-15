#include "game_rules.h"
#include <fstream>

GameRules::GameRules() {}

GameRules::GameRules(std::string rules_filename) {
  json j;
  std::ifstream in("rules.json");
  in >> j;
  *this = j;
}

void to_json(json &j, const GameRules &rules) {
  for (auto it = rules.unit_kinds.begin(); it != rules.unit_kinds.end(); it++) {
    j["unit_kinds"].push_back(it->second);
  }
  j["starting_resources"] = rules.starting_resources;
  for (auto it = rules.starting_units.begin(); it != rules.starting_units.end(); it++) {
    j["starting_units"].push_back((*it)->get_id());
  }
}

void from_json(const json &j, GameRules &rules) {
  for (auto it = j["unit_kinds"].begin(), end = j["unit_kinds"].end(); it != end; it++) {
    rules.unit_kinds.emplace((*it)["id"].get<std::string>(), *it);
  }
  rules.starting_resources = j["starting_resources"];
  rules.starting_units = std::vector<UnitKind*>();
  for (auto it = j["starting_units"].begin(), end = j["starting_units"].end(); it != end; it++) {
    rules.starting_units.push_back(&rules.unit_kinds.at(*it));
  }
}

const UnitKind &GameRules::get_unit_kind(std::string id) const {
  return unit_kinds.at(id);
}

unsigned short GameRules::get_starting_resources() const {
  return starting_resources;
}

const std::vector<UnitKind*> &GameRules::get_starting_units() const {
  return starting_units;
}
