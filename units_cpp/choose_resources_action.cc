#include "action.h"
#include "choose_resources_action.h"
#include "resources.h"

ChooseResourcesAction::ChooseResourcesAction(const Resources &r)
  : Action(CHOOSE_RESOURCES), resources(r) {}

const Resources &ChooseResourcesAction::get_resources() const {
  return resources;
}
