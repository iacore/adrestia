#pragma once
#include "action.h"
#include "resources.h"

class ChooseResourcesAction : public Action {
 public:
  ChooseResourcesAction(const Resources &r);
  const Resources &get_resources() const;
 private:
  Resources resources;
};

