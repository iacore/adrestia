#include <vector>
#include "action.h"
#include "build_units_action.h"
#include "unit_kind.h"

BuildUnitsAction::BuildUnitsAction(std::vector<const UnitKind*> units)
  : Action(BUILD_UNITS), units(units) {}

const std::vector<const UnitKind*> &BuildUnitsAction::get_units() const {
  return units;
}
