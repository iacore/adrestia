#include "action.h"

Action::Action(ActionType type) : type(type) {}

ActionType Action::get_type() const {
  return type;
}
