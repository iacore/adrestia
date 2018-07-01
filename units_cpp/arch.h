#include <string>
#include <vector>

#include "json.hpp"

using json = nlohmann::json;

enum Colour { BLACK, RED, GREEN, BLUE };

class Resources {
 public:
  unsigned short red;
  unsigned short green;
  unsigned short blue;

  Resources(unsigned short red, unsigned short green, unsigned short blue);
  void add(const Resources &r);
  void subtract(const Resources &r);
  bool subsumes(const Resources &r);
};

class UnitKind {
 public:
  UnitKind(json data);
  ~UnitKind();
  std::string get_name() const;
  Colour get_colour() const;
  unsigned short get_health() const;
  unsigned short get_width() const;
  const unsigned short *get_attack() const;
  const Resources *get_resources() const;
  const Resources *get_font() const;
  std::string get_image() const;
  const unsigned short *get_tiles() const;
  char get_label() const;
 private:
  std::string name;
  Colour colour;
  unsigned short health;
  unsigned short width;
  unsigned short *attack;
  Resources *cost; // nullptr for no cost
  Resources *font; // nullptr for no font behaviour
  std::string image;
  unsigned short *tiles;
  char label;
};

class Unit {
 public:
  Unit(const UnitKind &kind);
  Unit(const Unit &unit);

  const UnitKind &kind;
  unsigned short health;
};

class PlayerView {
 public:
  PlayerView();

  std::vector<Unit> units;
  bool alive;
};

class Player {
 public:
  Player();
   
  std::vector<Unit> units;
  bool alive;
  Resources production;
  Resources resources;
};

class GameRules {
 public:
  GameRules(json data);
  const UnitKind &get_unit_kind(std::string id) const;
  unsigned short get_starting_resources() const;
 private:
  std::map<std::string, UnitKind> unit_kinds;
  unsigned short starting_resources;
};

enum ActionType { CHOOSE_RESOURCES = 0, BUILD_UNITS };
class Action {
 public:
  Action(ActionType type);
  ActionType get_type() const;
 private:
  ActionType type;
};

class ChooseResourcesAction : Action {
 public:
  ChooseResourcesAction(const Resources &r);
  const Resources &get_resources() const;
 private:
  Resources resources;
};

class BuildUnitsAction : Action {
 public:
  BuildUnitsAction(const std::vector<UnitKind> &units);
  const std::vector<UnitKind> &get_units() const;
 private:
  std::vector<UnitKind> units;
};

class GameView {
 public:
  unsigned short view_player_id;
  Player player;
  std::vector<PlayerView> players;
};

class GameState {
 public:
  GameState(const GameRules &rules, unsigned short num_players);
  GameState(const GameState &game_state);
  bool perform_action(unsigned short player, const Action &action);
  const GameView &get_view(unsigned short player);
  std::vector<unsigned short> get_winners() const; // Empty list indicates that game is still in progress
 private:
  const GameRules &rules;
  std::vector<Player> players;
  unsigned int turn;
};
