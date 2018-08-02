#include "action.h"
#include "colour.h"

Action::Action() {}
Action::Action(Colour colour) : type(CHOOSE_TECH), colour(colour) {}
Action::Action(std::vector<std::string> units) : type(BUILD_UNITS), units(units) {}

ActionType Action::get_type() const {
  return type;
}

Colour Action::get_colour() const {
  return colour;
}

const std::vector<std::string> &Action::get_units() const {
  return units;
}

void to_json(json &j, const Action &a) {
  if (a.type == CHOOSE_TECH) {
    j["type"] = "CHOOSE_TECH";
    j["colour"] = a.colour;
  } else if (a.type == BUILD_UNITS) {
    j["type"] = "BUILD_UNITS";
    j["units"] = a.get_units();
  }
}

void from_json(const json &j, Action &a) {
  if (j["type"] == "CHOOSE_TECH") {
    a.type = CHOOSE_TECH;
    a.colour = j["colour"];
  } else if (j["type"] == "BUILD_UNITS") {
    a.type = BUILD_UNITS;
    for (auto it = j["units"].begin(), end = j["units"].end(); it != end; it++) {
      a.units.push_back(*it);
    }
  }
}

bool operator==(const Action &a1, const Action &a2) {
  if (a1.get_type() != a2.get_type()) return false;
  if (a1.get_type() == CHOOSE_TECH) {
    return a1.get_colour() == a2.get_colour();
  } else if (a1.get_type() == BUILD_UNITS) {
    if (a1.get_units().size() != a2.get_units().size()) return false;
    for (int i = 0; i < a1.get_units().size(); i++) {
      if (a1.get_units()[i] != a2.get_units()[i]) return false;
    }
    return true;
  }
  return false;
}
