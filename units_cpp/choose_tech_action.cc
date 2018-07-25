#include "action.h"
#include "choose_tech_action.h"
#include "colour.h"

ChooseTechAction::ChooseTechAction(Colour colour)
  : Action(CHOOSE_TECH), colour(colour) {}

Colour ChooseTechAction::get_colour() const {
  return colour;
}
