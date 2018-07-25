#pragma once
#include "action.h"
#include "colour.h"

class ChooseTechAction : public Action {
 public:
  ChooseTechAction(Colour colour);
  Colour get_colour() const;
 private:
  Colour colour;
};

