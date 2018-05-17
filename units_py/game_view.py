import attr
import copy
from typing import List

from game_state import GameState
from player import Player
from unit import Unit

@attr.s
class OtherPlayer:
    name: str         = attr.ib()
    units: List[Unit] = attr.ib()
    alive: bool       = attr.ib()

    @staticmethod
    def of_player(player: Player) -> 'OtherPlayer':
        return OtherPlayer(name=player.name, units=player.units[:], alive=player.alive)

@attr.s
class GameView:
    view_player: Player              = attr.ib()
    other_players: List[OtherPlayer] = attr.ib()
    turn: int                        = attr.ib()

    @staticmethod
    def of_gamestate(game: GameState, player_index: int) -> 'GameView':
        return GameView(view_player=copy.deepcopy(game.players[player_index]),
                        other_players=[OtherPlayer.of_player(p) for i, p in enumerate(game.players) if i != player_index],
                        turn=game.turn)
