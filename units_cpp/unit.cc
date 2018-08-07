#include "unit.h"
#include "json.h"
#include "game_rules.h"

Unit::Unit() {}

Unit::Unit(const UnitKind &kind)
  : kind(&kind)
  , health(kind.get_health())
  , shields(kind.get_shields())
  , build_time(kind.get_build_time()) {
}

Unit::Unit(const Unit &unit)
  : kind(unit.kind)
  , health(unit.health)
  , shields(unit.shields)
  , build_time(unit.build_time) {
}

void to_json(json &j, const Unit &unit) {
  j["kind"] = unit.kind->get_id();
  j["health"] = unit.health;
  j["shields"] = unit.shields;
  j["build_time"] = unit.build_time;
}

void from_json(const json &j, Unit &unit) {
  unit.kind = &GameRules::get_instance().get_unit_kind(j["kind"]);
  unit.health = j["health"];
  unit.shields = j["shields"];
  unit.build_time = j["build_time"];
}
