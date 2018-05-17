from typing import List, Optional, Callable, Dict
import itertools
import attr
import os

from colour import Colour
from resources import Resources
from unit_kind import UnitKind, unit_kinds
from unit import Unit
from player import Player
from game_state import GameState

from game_view import GameView, OtherPlayer
from strategy import Strategy

################################################################################
# Text-based manual playtesting system
################################################################################

# Done type declaration; here are helper methods for actually running the game
def read_production(player_name: str) -> Resources:
    while True:
        print('{}\'s production (R G B): '.format(player_name), end='')
        production: Resources = Resources.of_string_exn(input())
        if production.red + production.green + production.blue != 7:
            print('Must sum to 7')
            continue
        return production

if __name__ == '__main__':
    state: GameState = GameState.create()
    print('Starting game.')
    for name in ['Alice', 'Bob']:
        os.system('clear')
        state.players.append(Player.create(name, read_production(name)))

    # Main game loop
    while True:
        # Production
        for player in state.players:
            player.resources.add(player.production)

            # Pre-turn effects
            for unit in player.units:
                if unit.kind.before_turn is not None:
                    unit.kind.before_turn(player)

        unit_caches = [(player.name, '{}\'s units:\n'.format(player.name) + '\n'.join(u.to_string_hum() for u in player.units)) for player in state.players]

        # Build
        for player in state.players:
            os.system('clear')
            print('\nPress enter to start turn')
            input()
            print('Player: {}'.format(player.name))
            for other, cache in unit_caches:
                if other == player.name: continue
                print(cache)
                print()
            while True:
                print('Resources available: {}'.format(player.resources.to_string_hum()))
                print('Your units:\n' + '\n'.join(u.to_string_hum() for u in player.units))
                print()
                print('Type a unit name to buy it, or "done".')
                print('Available units: ' + ' '.join(unit_kinds.keys()))
                cmd = input()
                if cmd == 'done': break
                unit_kind = unit_kinds.get(cmd)
                if unit_kind is None:
                    print('Invalid unit')
                    continue
                if unit_kind.cost is None:
                    print('Cannot buy.')
                    continue
                if not player.resources.subsumes(unit_kind.cost):
                    print('Cannot afford.')
                    continue
                player.resources.subtract(unit_kind.cost)
                player.units.append(Unit.of_kind(unit_kind))

        # Battle
        os.system('clear')
        for player in state.players:
            target_units = list(itertools.chain.from_iterable(p.units for p in state.players if p is not player))
            total_width = sum(u.kind.width for u in target_units)
            for attacker in player.units:
                for attack in attacker.kind.attack:
                    width_left = random.randint(0, total_width - 1)
                    target: Optional[Unit] = None
                    for u in target_units:
                        width_left -= u.kind.width
                        if width_left < 0:
                            target = u
                            break
                    if target is None:
                        raise Exception('Invalid target during battle')
                    target.health -= attack
                    message = f"{player.name}'s {attacker.kind.name} hits {target.kind.name} for {attack}"
                    if target.health <= 0: message += ", killing it!"
                    print(message)
        print('\nPress enter to continue')
        input()

        # Death
        for player in state.players:
            player.units = [u for u in player.units if u.health > 0]
            player.alive = next((u for u in player.units if u.kind is unit_kinds['general']), None) is not None
        
        remaining_players = [p for p in state.players if p.alive]
        if len(remaining_players) < 2:
            if len(remaining_players) == 1:
                print(f'{remaining_players[0].name} wins!')
            else:
                print('It is a tie!')
            break
        print()
