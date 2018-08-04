#include <iostream>
#include "../action.h"
#include "../game_state.h"
#include "../game_rules.h"
#include "../json.h"

using namespace std;
using json = nlohmann::json;

int main() {
  cout << " ______ ______ " << endl;
  cout << "|      T      |" << endl;
  cout << "A d r e|s t i A" << endl;
  cout << "       |       " << endl;
  cout << "      /_\\   " << endl;
  cout << endl;

  GameRules rules("rules.json");
  GameState game(rules, 2);

  string input;

  cout << "Unit cap: " << rules.get_unit_cap() << endl;
  cout << "Units: ";
  bool first = true;
  for (const auto &[unit_name, unit_kind] : rules.get_unit_kinds()) {
    if (first) { first = false; } else { cout << ", "; }
    cout << unit_name;
  }
  cout << endl;

  while (game.get_winners().size() == 0) {
    cout << "=== Turn " << game.get_turn() << " ===" << endl;
    cout << "Game state:" << endl;
    const vector<Player> &players = game.get_players();
    for (size_t pid = 0; pid < players.size(); pid++) {
      const Player &player = players[pid];
      cout
        << "Player " << pid << ": "
        << "(tech: " << json(player.tech)
        << ") (coins: " << player.coins
        << ")" << endl;
      cout << "Player " << pid << " units:" << endl;
      for (const auto &[unit_id, unit] : player.units) {
        cout
          << "("
          << unit.health << "/" << unit.kind.get_health() << " "
          << unit.kind.get_name()
          << ") " << endl;
      }
    }
    for (size_t pid = 0; pid < players.size(); pid++) {
      const Player &player = players[pid];
      cout << "--- Player " << pid << " ---" << endl;
      Colour colour = BLACK;
      while (colour == BLACK) {
        cout << "Pick tech to advance [R|G|B]: ";
        cin >> input;
        switch (input[0]) {
          case 'R': colour = RED; break;
          case 'G': colour = GREEN; break;
          case 'B': colour = BLUE; break;
          default: cout << "Invalid choice." << endl; break;
        }
      }
      if (game.perform_action(pid, Action(colour))) {
        cout << "New tech: " << json(player.tech) << endl;
      } else {
        cout << "Failure." << endl;
        return 1;
      }
      cout << "Time to buy units! 'done' ends turn. You have tech for:" << endl;
      for (const auto &[unit_name, unit_kind] : rules.get_unit_kinds()) {
        const auto tech = unit_kind.get_tech();
        if (tech && player.tech.includes(*tech)) {
          cout << unit_kind.get_id() << " (costs " << unit_kind.get_cost() << ")" << endl;
        }
      }
      int coins_spent = 0;
      vector<string> units_to_buy;
      while (true) {
        int coins_left = player.coins - coins_spent;
        cout << player.coins - coins_spent << " coins left." << endl;
        cout << "> ";
        cin >> input;
        if (input == "done") {
          break;
        }
        try {
          const UnitKind &kind = rules.get_unit_kind(input);
          if (kind.get_cost() <= coins_left) {
            units_to_buy.push_back(string(input));
            coins_spent += kind.get_cost();
            cout << "OK. ";
          } else {
            cout << "Cannot afford. ";
          }
        } catch (...) {
          cout << "Invalid unit." << endl;
        }
      }
      if (game.perform_action(pid, Action(units_to_buy))) {
        cout << "Success." << endl;
      } else {
        cout << "Failure." << endl;
        return 1;
      }

      // TODO(jim): display battle results
    }
  }
}
