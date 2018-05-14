from typing import List, Optional, Callable, Dict
from enum import Enum
import random
import itertools

class Colour(Enum):
    BLACK = 0
    RED = 1
    GREEN = 2
    BLUE = 3

class Resources:
    red: int
    green: int
    blue: int

    def __init__(self, red: int = 0, green: int = 0, blue: int = 0) -> None:
        self.red = red
        self.green = green
        self.blue = blue

    @staticmethod
    def of_string_exn(s: str) -> 'Resources':
        red, green, blue = map(int, s.split(' '))
        return Resources(red=red, green=green, blue=blue)
    
    def to_string_hum(self) -> str:
        return '((red {}) (green {}) (blue {})'.format(self.red, self.green, self.blue)
    
    def subsumes(self, other: 'Resources') -> bool:
        return self.red >= other.red and self.green >= other.green and self.blue >= other.blue

    def add(self, other: 'Resources') -> 'Resources':
        return Resources(
                red=self.red + other.red,
                green=self.green + other.green,
                blue=self.blue + other.blue)

    def subtract(self, other: 'Resources') -> 'Resources':
        return Resources(
                red=self.red - other.red,
                green=self.green - other.green,
                blue=self.blue - other.blue)

class UnitKind:
    name: str
    colour: Colour
    health: int
    width: int
    attack: List[int]
    cost: Optional[Resources]
    before_turn: Optional[Callable[['Player'], None]]

    def __init__(
            self,
            name: str,
            colour: Colour,
            health: int,
            width: int,
            attack: List[int],
            cost: Optional[Resources],
            before_turn: Optional[Callable[['Player'], None]] = None,
            ) -> None:
        self.name = name
        self.colour = colour
        self.health = health
        self.width = width
        self.attack = attack
        self.cost = cost
        self.before_turn = before_turn

def add_resources_effect(resources: Resources) -> Callable[['Player'], None]:
    def inner(p: 'Player') -> None:
        p.resources = p.resources.add(resources)
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

class Unit:
    kind: UnitKind
    health: int

    def __init__(self, kind: UnitKind) -> None:
        self.kind = kind
        self.health = kind.health

    def to_string_hum(self) -> str:
        return '({} (width {}) (hp {}/{}){})'.format(
                self.kind.name,
                self.kind.width,
                self.health,
                self.kind.health,
                ' (attack {})'.format(self.kind.attack) if len(self.kind.attack) > 0 else '')

class Player:
    name: str
    units: List[Unit]
    resources: Resources
    production: Resources
    done_turn: bool
    alive: bool

    def __init__(self, name: str, production: Resources) -> None:
        self.name = name
        self.resources = Resources()
        self.production = production
        self.units = [Unit(unit_kinds['general'])]
        self.done_turn = False
        self.alive = True

class GameState:
    players: List['Player']
    turn: int

    def __init__(self) -> None:
        self.players = []
        self.turn = 0

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
    state: GameState = GameState()
    print('Starting game.')
    for name in ['Alice', 'Bob']:
        state.players.append(Player(name, read_production(name)))

    # Main game loop
    while True:
        # Production
        for player in state.players:
            player.resources = player.resources.add(player.production)

            # Pre-turn effects
            for unit in player.units:
                if unit.kind.before_turn is not None:
                    unit.kind.before_turn(player)

        # Build
        for player in state.players:
            print('Player: {}'.format(player.name))
            while True:
                print('Resources available: {}'.format(player.resources.to_string_hum()))
                print('Your units:\n' + '\n'.join(u.to_string_hum() for u in player.units))
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
                player.resources = player.resources.subtract(unit_kind.cost)
                player.units.append(Unit(unit_kind))

        # Battle
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

        # Death
        for player in state.players:
            player.units = [u for u in player.units if u.health > 0]
            player.alive = next((u for u in player.units if u.kind is unit_kinds['general']), None) is not None
        
        remaining_players = [p for p in state.players if p.alive]
        if len(remaining_players) < 2:
            if len(remaining_players) == 1:
                print('{} wins!'.format(remaining_players[0].name))
            else:
                print('It is a tie!')
            break

