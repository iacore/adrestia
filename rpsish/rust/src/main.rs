extern crate rand;
extern crate num;

use num::integer::Integer;
use rand::Rng;
use std::cmp::Ordering;

trait GameState<'a> {
  type Action;
  fn done(&self) -> bool;
  fn apply_action(&mut self, &Self::Action);
  fn moves(&self) -> Vec<Self::Action>;
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
struct RpsishAction {
  player: usize,
  public_symbol: usize,
  private_symbol: usize,
}

impl<'a> GameState<'a> for RpsishState<'a> {
  type Action = RpsishAction;

  fn done(&self) -> bool {
    let num_rounds = self.config.num_rounds;
    self.private_symbols.into_iter().all(|v| v.len() >= num_rounds)
  }
  fn apply_action(&mut self, action: &RpsishAction) {
    self.public_symbols[self.player].push(action.public_symbol);
    self.private_symbols[self.player].push(action.private_symbol);
    self.player = (self.player + 1) % 2;
  }
  fn moves(&self) -> Vec<RpsishAction> {
    // TODO: implement
    vec![]
  }
}

impl<'a> RpsishState<'a> {
  fn calc_score(&self) -> i32 {
    let mut p1 = self.private_symbols[0].clone();
    p1.append(&mut self.public_symbols[0].clone());
    let mut p2 = self.private_symbols[1].clone();
    p2.append(&mut self.public_symbols[1].clone());
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
  while !state.done() {
    let action = RpsishAction {
      player:         state.player,
      public_symbol:  modulo(rand::thread_rng().gen::<usize>(), config.num_symbols),
      private_symbol: modulo(rand::thread_rng().gen::<usize>(), config.num_symbols),
    };
    state.apply_action(&action);
    println!("{:?}", state);
  }

  let score = state.calc_score();
  println!("Final score: {:?}", score);

  match score.cmp(&0) {
    Ordering::Greater => println!("Player 1 wins!"),
    Ordering::Less    => println!("Player 2 wins!"),
    Ordering::Equal   => println!("It is a tie!"),
  }
}
