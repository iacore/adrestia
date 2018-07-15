#pragma once
#include <vector>
#include "action.h"
#include "unit_kind.h"

class BuildUnitsAction : public Action {
 public:
  BuildUnitsAction(std::vector<const UnitKind*> units);
  const std::vector<const UnitKind*> &get_units() const;
 private:
  std::vector<const UnitKind*> units;
};

