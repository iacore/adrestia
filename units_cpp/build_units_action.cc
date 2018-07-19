#include <vector>
#include "action.h"
#include "build_units_action.h"
#include "unit_kind.h"

BuildUnitsAction::BuildUnitsAction(std::vector<std::string> units)
  : Action(BUILD_UNITS), units(units) {}

const std::vector<std::string> &BuildUnitsAction::get_units() const {
  return units;
}
