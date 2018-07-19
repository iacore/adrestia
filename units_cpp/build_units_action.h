#pragma once
#include <vector>
#include "action.h"
#include "unit_kind.h"

class BuildUnitsAction : public Action {
 public:
  BuildUnitsAction(std::vector<std::string> units);
  const std::vector<std::string> &get_units() const;
 private:
  std::vector<std::string> units;
};

