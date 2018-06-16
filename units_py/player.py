import attr
from typing import List

from resources import Resources
from unit import Unit
from unit_kind import UnitKind, unit_kinds

@attr.s
class Player:
    name: str                         = attr.ib()
    units: List[Unit]                 = attr.ib()
    build_order: List[List[UnitKind]] = []
    resources: Resources              = attr.ib()
    production: Resources             = attr.ib()
    done_turn: bool                   = attr.ib(default = False)
    alive: bool                       = attr.ib(default = True)

    @staticmethod
    def create(name: str, production: Resources) -> 'Player':
        return Player(
                name = name,
                units = [Unit.of_kind(unit_kinds['general'])] + [Unit.of_kind(unit_kinds['wall']) for _ in range(5)],
                resources = Resources(),
                production = production)
