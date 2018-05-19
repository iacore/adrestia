from typing import List, Tuple
import random

from strategy import Strategy, StrategyGenerator, NullStrategy
from basic_strategy import BasicStrategy, basic_strategy_generator
from simulator import simulate
from resources import Resources
from unit_kind import unit_kinds

def find_best_response(strategy: Strategy, generator: StrategyGenerator) -> Tuple[Strategy, float]:
    arms: List[Tuple[Strategy, Tuple[int, int]]] = []
    for i in range(5000):
        if len(arms) == 0 or random.random() < 0.5:
            candidate = generator()
            win = simulate([strategy, candidate])
            if win != -1:
                arms.append((candidate, (win, 1)))
        else:
            # Choose the best strategy by percentage of wins
            _, i = max((wins / games, i) for (i, (_, (wins, games))) in enumerate(arms))
            candidate, (wins, games) = arms[i]
            win = simulate([strategy, candidate])
            if win != -1:
                arms[i] = (candidate, (wins + win, games + 1))
    # Find the arm that has the highest win percentage among arms with at least 10 games
    _, i = max((wins / games, i) for (i, (_, (wins, games))) in enumerate(arms) if games >= 10)
    candidate, (wins, games) = arms[i]
    return candidate, wins / games

if __name__ == '__main__':
    current_best: Strategy = BasicStrategy(production=Resources(red=0, green=7, blue=0),
                                           build_order=[unit_kinds['turret']] * 4)
    for i in range(10):
        new_strategy, win_percent = find_best_response(current_best, basic_strategy_generator)
        print(new_strategy, win_percent)
        if win_percent > 0.5:
            current_best = new_strategy
