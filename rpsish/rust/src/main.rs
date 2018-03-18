extern crate rand;
extern crate num;

use num::integer::Integer;
use rand::Rng;
use std::cmp::Ordering;

trait GameState<'a> {
  type View;
  type Action;
  fn done(&self) -> bool;
  fn apply_action(&mut self, &Self::Action);
  fn moves(&self) -> Vec<Self::Action>;
  fn to_view(&self, usize) -> Self::View;
}

trait Player<'a> {
  type Game : GameState<'a>;

  /* Note: We have to explicitly annotate Self::Game as GameState<'a> in this signature because
   * https://github.com/rust-lang/rust/issues/38078 ... and we can't define a type alias for it
   * because https://github.com/rust-lang/rust/issues/29661 */
  fn make_move(&self, usize, &<Self::Game as GameState<'a>>::View)
    -> <Self::Game as GameState<'a>>::Action;
}

#[derive(Debug)]
struct RpsishConfig {
  num_symbols: usize,
  payoffs: Vec<Vec<i32>>,
  num_rounds: usize,
}

#[derive(Debug)]
struct RpsishState<'a> {
  config: &'a RpsishConfig,
  player: usize,
  public_symbols: [Vec<usize>; 2],
  private_symbols: [Vec<usize>; 2],
}

#[derive(Debug)]
struct RpsishView<'a> {
  config: &'a RpsishConfig,
  public_symbols: [Vec<usize>; 2],
  my_private_symbols: Vec<usize>,
}

#[derive(Debug)]
struct RpsishAction {
  player: usize,
  public_symbol: usize,
  private_symbol: usize,
}

impl<'a> GameState<'a> for RpsishState<'a> {
  type View = RpsishView<'a>;
  type Action = RpsishAction;

  fn done(&self) -> bool {
    let num_rounds = self.config.num_rounds;
    self.private_symbols.into_iter().all(|x| x.len() >= num_rounds)
  }

  fn apply_action(&mut self, action: &RpsishAction) {
    self.public_symbols [self.player].push(action.public_symbol);
    self.private_symbols[self.player].push(action.private_symbol);
    self.player = (self.player + 1) % 2;
  }

  fn to_view(&self, pid: usize) -> RpsishView<'a> {
    RpsishView {
      config: &self.config,
      public_symbols: self.public_symbols.clone(),
      my_private_symbols: self.private_symbols[pid].clone(),
    }
  }

  fn moves(&self) -> Vec<RpsishAction> {
    // TODO: implement
    vec![]
  }
}

struct RandomPlayer;
impl<'a> Player<'a> for RandomPlayer {
  type Game = RpsishState<'a>;
  fn make_move(&self, pid: usize, view: &RpsishView) -> RpsishAction {
    RpsishAction {
      player:         pid,
      public_symbol:  modulo(rand::thread_rng().gen::<usize>(), view.config.num_symbols),
      private_symbol: modulo(rand::thread_rng().gen::<usize>(), view.config.num_symbols),
    }
  }
}

struct AlwaysZeroPlayer;
impl<'a> Player<'a> for AlwaysZeroPlayer {
  type Game = RpsishState<'a>;
  fn make_move(&self, pid: usize, _view: &RpsishView) -> RpsishAction {
    RpsishAction {
      player:         pid,
      public_symbol:  0,
      private_symbol: 0,
    }
  }
}

impl<'a> RpsishState<'a> {
  fn calc_score(&self, pid: usize) -> i32 {
    let you = (pid + 1) % 2;
    let mut p1 =   self.private_symbols[pid].clone();
    p1.append(&mut self.public_symbols [pid].clone());
    let mut p2 =   self.private_symbols[you].clone();
    p2.append(&mut self.public_symbols [you].clone());
    let mut score = 0;
    for &s in &p1 {
      for &t in &p2 {
        score += self.config.payoffs[s][t];
      }
    }
    score
  }
}

fn modulo<T: Integer + Copy>(x: T, m: T) -> T {
  ((x % m) + m) % m
}

fn main() {
  let config = RpsishConfig {
    num_symbols: 3,
    /* 0 beats 1 beats 2 beats 0 */
    payoffs: vec![
      vec![0, 1, -1],
      vec![-1, 0, 1],
      vec![1, -1, 0],
    ],
    num_rounds: 5,
  };
  let mut state = RpsishState {
    config: &config,
    player: 0,
    public_symbols:  [Vec::new(), Vec::new()],
    private_symbols: [Vec::new(), Vec::new()],
  };
  let players: Vec<Box<Player<Game=RpsishState>>> = vec![
    Box::new(RandomPlayer),
    Box::new(AlwaysZeroPlayer),
  ];
  while !state.done() {
    let view = state.to_view(state.player);
    let action = players[state.player].make_move(state.player, &view);
    state.apply_action(&action);
  }

  println!("Player 0's public symbols:  {:?}", state.public_symbols [0]);
  println!("Player 0's private symbols: {:?}", state.private_symbols[0]);
  println!("Player 1's public symbols:  {:?}", state.public_symbols [1]);
  println!("Player 1's private symbols: {:?}", state.private_symbols[1]);

  let score = state.calc_score(0);
  println!("Final score: {:?}", score);

  match score.cmp(&0) {
    Ordering::Greater => println!("Player 0 wins!"),
    Ordering::Less    => println!("Player 1 wins!"),
    Ordering::Equal   => println!("It is a tie!"),
  }
}
