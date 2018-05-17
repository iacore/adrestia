from abc import ABC, abstractmethod
from typing import Callable, List

from game_view import GameView
from unit_kind import UnitKind
from resources import Resources

class Strategy(ABC):
    @abstractmethod
    def getProduction(self) -> Resources:
        raise NotImplementedError

    @abstractmethod
    def doTurn(self, game_view: GameView) -> List[UnitKind]:
        raise NotImplementedError

StrategyGenerator = Callable[[], Strategy]
