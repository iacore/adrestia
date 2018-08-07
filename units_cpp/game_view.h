#pragma once
#include <vector>
#include <memory>
#include "player_view.h"
#include "game_rules.h"
#include "action.h"
#include "battle.h"

class GameView {
 public:
  GameView();
  std::vector<Action> legal_actions();

  const GameRules *rules;
  int view_index;
  Player view_player;
  std::vector<PlayerView> players;
  std::vector<std::vector<std::vector<Action>>> action_log;
  const std::vector<std::shared_ptr<Battle>> *battles;
  int turn;

 private:
  void generate_build_units_actions(std::vector<Action> &actions,
      std::vector<std::string> &units,
      int coins,
      std::map<std::string, UnitKind>::const_iterator begin,
      std::map<std::string, UnitKind>::const_iterator end);
};
