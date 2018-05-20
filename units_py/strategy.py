from abc import ABC, abstractmethod
from typing import Callable, List

from game_view import GameView
from unit_kind import UnitKind
from resources import Resources

class Strategy(ABC):
    @abstractmethod
    def get_production(self) -> Resources:
        raise NotImplementedError

    @abstractmethod
    def do_turn(self, game_view: GameView) -> List[UnitKind]:
        raise NotImplementedError

    @abstractmethod
    def mutate(self) -> 'Strategy':
        raise NotImplementedError

StrategyGenerator = Callable[[], Strategy]

class NullStrategy(Strategy):
    def get_production(self) -> Resources:
        return Resources(red=3, green=2, blue=2)
    
    def do_turn(self, game_view: GameView) -> List[UnitKind]:
        return []

    def mutate(self) -> Strategy:
        return NullStrategy()
