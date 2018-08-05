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

  const GameRules *rules;
  Player view_player;
  std::vector<PlayerView> players;
  const std::vector<std::vector<std::vector<Action>>> *action_log;
  const std::vector<std::shared_ptr<Battle>> *battles;
  int turn;
};
