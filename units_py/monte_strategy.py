from abc import ABC, abstractmethod
import attr
import copy
import random
import math
from typing import List, Optional, Tuple

from game_view import GameView, OtherPlayer
from game_state import GameState
from resources import Resources
from strategy import Strategy
from unit_kind import UnitKind, unit_kinds

# r is a tuple of (min_resources, observed_resources), where
# min_resources is the minimum allocation to each colour necessary to be able to afford the observed units, and
# observed_resources is how much the player has been observed to spend, less any resources produced by fonts
def update_observed_resources(r: Tuple[Resources, Resources], p: OtherPlayer, turn: int) -> Tuple[Resources, Resources]:
    min_resources, observed_resources = r
    if len(p.build_order) > 0:
        for k in p.build_order[-1]:
            if k.cost is not None:
                observed_resources.add(k.cost)
    if turn > 0:
        min_resources.red = max(math.ceil(observed_resources.red / turn), min_resources.red)
        min_resources.green = max(math.ceil(observed_resources.green / turn), min_resources.green)
        min_resources.blue = max(math.ceil(observed_resources.blue / turn), min_resources.blue)
    for u in p.units:
        if u.kind.font:
            observed_resources.subtract(u.kind.font)
    return (min_resources, observed_resources)

# List of possible build orders given the available resources
def possible_build_orders(resources: Resources) -> List[List[UnitKind]]:
    build_orders = []
    unit_kind_list = [k for k in unit_kinds.values() if k.cost is not None]
    def aux(build_order: List[UnitKind], r: Resources, unit_kind_index: int) -> None:
        if unit_kind_index >= len(unit_kind_list):
            build_orders.append(build_order)
            return
        kind = unit_kind_list[unit_kind_index]
        if kind.cost is not None and r.subsumes(kind.cost):
            nr = Resources(r.red, r.green, r.blue)
            nr.subtract(kind.cost)
            aux(build_order + [kind], nr, unit_kind_index)
        aux(build_order, r, unit_kind_index + 1)
    aux([], resources, 0)
    return build_orders

class PartialStrategy(ABC):
    @abstractmethod
    def get_production(self) -> Optional[Resources]:
        raise NotImplementedError

    @abstractmethod
    def do_turn(self, game_view: GameView) -> Optional[List[UnitKind]]:
        raise NotImplementedError

class MonteStrategy(Strategy):
    partial_strategy: PartialStrategy
    observed_resources: Optional[List[Tuple[Resources, Resources]]]
    turn: int

    def __init__(self, partial_strategy: PartialStrategy) -> None:
        self.partial_strategy = partial_strategy
        self.observed_resources = None
        self.turn = 0

    def get_production(self) -> Resources:
        p = self.partial_strategy.get_production()
        if p is not None:
            return p
        # TODO: determine resources to use by simulation
        return Resources(3, 2, 2)

    def do_turn(self, view: GameView) -> List[UnitKind]:
        # Always update resources
        if self.observed_resources is None:
            self.observed_resources = [(Resources(), Resources()) for _ in view.other_players]
        for i, p in enumerate(view.other_players):
            self.observed_resources[i] = update_observed_resources(self.observed_resources[i], p, self.turn)

        t = self.partial_strategy.do_turn(view)
        if t is not None:
            self.turn += 1
            return t

        # Determine all possible build orders for this turn
        return []
