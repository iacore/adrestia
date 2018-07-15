#pragma once

enum ActionType { CHOOSE_RESOURCES = 0, BUILD_UNITS };
class Action {
 public:
  Action(ActionType type);
  ActionType get_type() const;
 private:
  ActionType type;
};

