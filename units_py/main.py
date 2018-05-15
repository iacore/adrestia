from typing import List, Optional, Callable, Dict
from enum import Enum
import random
import itertools
import attr
import os

class Colour(Enum):
    BLACK = 0
    RED = 1
    GREEN = 2
    BLUE = 3

@attr.s
class Resources:
    red: int   = attr.ib(default = 0)
    green: int = attr.ib(default = 0)
    blue: int  = attr.ib(default = 0)

    @staticmethod
    def of_string_exn(s: str) -> 'Resources':
        red, green, blue = map(int, s.split(' '))
        return Resources(red=red, green=green, blue=blue)
    
    def to_string_hum(self) -> str:
        return '((red {}) (green {}) (blue {})'.format(self.red, self.green, self.blue)
    
    def subsumes(self, other: 'Resources') -> bool:
        return self.red >= other.red and self.green >= other.green and self.blue >= other.blue

    def add(self, other: 'Resources') -> None:
        self.red += other.red
        self.green += other.green
        self.blue += other.blue

    def subtract(self, other: 'Resources') -> None:
        self.red -= other.red
        self.green -= other.green
        self.blue -= other.blue

@attr.s
class UnitKind:
    name: str                                         = attr.ib()
    colour: Colour                                    = attr.ib()
    health: int                                       = attr.ib()
    width: int                                        = attr.ib()
    attack: List[int]                                 = attr.ib()
    cost: Optional[Resources]                         = attr.ib()
    before_turn: Optional[Callable[['Player'], None]] = attr.ib(default = None)

def add_resources_effect(resources: Resources) -> Callable[['Player'], None]:
    def inner(p: 'Player') -> None:
        p.resources.add(resources)
    return inner

unit_kinds: Dict[str, UnitKind] = {
    'general': UnitKind(name='General', colour=Colour.BLACK, health=5, width=1, attack=[1], cost=None),
    'grunt': UnitKind(name='Grunt', colour=Colour.RED, health=1, width=1, attack=[1], cost=Resources(red=2)),
    'troll': UnitKind(name='Troll', colour=Colour.RED, health=2, width=2, attack=[4], cost=Resources(red=5)),
    'wall': UnitKind(name='Wall', colour=Colour.GREEN, health=1, width=1, attack=[], cost=Resources(green=1)),
    'turret': UnitKind(name='Turret', colour=Colour.GREEN, health=1, width=2, attack=[1], cost=Resources(green=2)),
    'wide_wall': UnitKind(name='Wide Wall', colour=Colour.GREEN, health=2, width=4, attack=[], cost=Resources(green=3)),
    'font_r': UnitKind(name='Font R', colour=Colour.BLUE, health=2, width=1, attack=[], cost=Resources(red=1, blue=2),
        before_turn=add_resources_effect(Resources(red=1))),
    'font_g': UnitKind(name='Font G', colour=Colour.BLUE, health=2, width=1, attack=[], cost=Resources(green=1, blue=2),
        before_turn=add_resources_effect(Resources(green=1))),
    'font_b': UnitKind(name='Font B', colour=Colour.BLUE, health=2, width=1, attack=[], cost=Resources(blue=3),
        before_turn=add_resources_effect(Resources(blue=1))),
    'paragon': UnitKind(name='Paragon', colour=Colour.BLUE, health=2, width=1, attack=[], cost=Resources(red=1, green=1, blue=7),
        before_turn=add_resources_effect(Resources(red=1, green=1, blue=1))),
    'ogre': UnitKind(name='Ogre', colour=Colour.RED, health=2, width=2, attack=[2], cost=Resources(red=2, green=2)),
    'shrek': UnitKind(name='Shrek', colour=Colour.GREEN, health=4, width=3, attack=[2], cost=Resources(red=2, green=3)),
    'soldier': UnitKind(name='Soldier', colour=Colour.BLUE, health=1, width=1, attack=[1], cost=Resources(red=1, blue=2)),
    'commando': UnitKind(name='Commando', colour=Colour.RED, health=2, width=1, attack=[1, 1], cost=Resources(red=3, blue=2)),
    # TODO: forts don't take damage from red units
    'fort': UnitKind(name='Fort', colour=Colour.GREEN, health=1, width=4, attack=[], cost=Resources(green=3, blue=2)),
    'insurgent': UnitKind(name='Insurgent', colour=Colour.RED, health=3, width=1, attack=[1], cost=Resources(red=2, green=1, blue=1)),
    'avatar': UnitKind(name='Avatar', colour=Colour.BLUE, health=3, width=2, attack=[1, 3, 1], cost=Resources(red=5, green=1, blue=3)),
    'tank': UnitKind(name='Tank', colour=Colour.BLUE, health=10, width=7, attack=[2], cost=Resources(red=1, green=5, blue=3)),
}

@attr.s
class Unit:
    kind: UnitKind = attr.ib()
    health: int    = attr.ib()

    @staticmethod
    def of_kind(kind: UnitKind) -> 'Unit':
        return Unit(kind, kind.health)

    def to_string_hum(self) -> str:
        return '({} (width {}) (hp {}/{}){})'.format(
                self.kind.name,
                self.kind.width,
                self.health,
                self.kind.health,
                ' (attack {})'.format(self.kind.attack) if len(self.kind.attack) > 0 else '')

@attr.s
class Player:
    name: str             = attr.ib()
    units: List[Unit]     = attr.ib()
    resources: Resources  = attr.ib()
    production: Resources = attr.ib()
    done_turn: bool       = attr.ib(default = False)
    alive: bool           = attr.ib(default = True)

    @staticmethod
    def create(name: str, production: Resources) -> 'Player':
        return Player(
                name = name,
                units = [Unit.of_kind(unit_kinds['general'])] + [Unit.of_kind(unit_kinds['wall']) for i in range(5)],
                resources = Resources(),
                production = production)

@attr.s
class GameState:
    players: List['Player'] = attr.ib()
    turn: int               = attr.ib()

    @staticmethod
    def create() -> 'GameState':
        return GameState(players=[], turn=0)

@attr.s
class OtherPlayer:
    name: str         = attr.ib()
    units: List[Unit] = attr.ib()
    alive: bool       = attr.ib()

    @staticmethod
    def of_player(player: Player) -> 'OtherPlayer':
        return OtherPlayer(name=player.name, units=player.units, alive=player.alive)

@attr.s
class GameView:
    view_player: Player              = attr.ib()
    other_players: List[OtherPlayer] = attr.ib()
    turn: int                        = attr.ib()

    @staticmethod
    def of_gamestate(game: GameState, player_index: int) -> 'GameView':
        return GameView(view_player=game.players[player_index],
                        other_players=[OtherPlayer.of_player(p) for i, p in enumerate(game.players) if i != player_index],
                        turn=game.turn)

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

