from typing import List

from strategy import Strategy
from human_strategy import HumanStrategy
from simulator import simulate

################################################################################
# Text-based manual playtesting system
################################################################################

if __name__ == '__main__':
    strategies: List[Strategy] = [HumanStrategy(), HumanStrategy()]
    simulate(strategies, debug=True)
