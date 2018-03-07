extern crate rand;
extern crate num;

use std::cmp::Ordering;
use rand::Rng;
use num::integer::Integer;

type PayoffTable = Vec<Vec<i32>>;

#[derive(Debug)]
struct GameConfig {
  num_symbols: usize,
  payoffs: PayoffTable,
  num_rounds: usize,
}

#[derive(Debug)]
struct GameState<'a> {
  config: &'a GameConfig,
  cur_player: usize,
  public_symbols: [Vec<usize>; 2],
  private_symbols: [Vec<usize>; 2],
}

#[derive(Debug)]
struct GameAction {
  public_symbol: usize,
  private_symbol: usize,
}

fn modulo<T: Integer + Copy>(x: T, m: T) -> T {
  ((x % m) + m) % m
}

fn apply_action(state: GameState, action: GameAction) -> GameState {
  // TODO: Use a non-zero-cost-abstraction to make this more concise
  let mut public_symbols = state.public_symbols.clone();
  public_symbols[state.cur_player].push(action.public_symbol);
  let mut private_symbols = state.private_symbols.clone();
  private_symbols[state.cur_player].push(action.private_symbol);
  GameState {
    cur_player: (state.cur_player + 1) % 2,
    public_symbols,
    private_symbols,
    ..state
  }
}

fn game_done(state: &GameState) -> bool {
  let num_rounds = state.config.num_rounds;
  state.private_symbols.into_iter().all(|v| v.len() >= num_rounds)
}

fn calc_score(state: &GameState) -> i32 {
  let mut p1 = state.private_symbols[0].clone(); p1.append(&mut state.public_symbols[0].clone());
  let mut p2 = state.private_symbols[1].clone(); p2.append(&mut state.public_symbols[1].clone());
  let mut score = 0;
  for s in &p1 {
    for t in &p2 {
      score += state.config.payoffs[*s][*t];
    }
  }
  score
}

fn main() {
  let config = GameConfig {
    num_symbols: 3,
    /* 0 beats 1 beats 2 beats 0 */
    payoffs: vec![
      vec![0, 1, -1],
      vec![-1, 0, 1],
      vec![1, -1, 0],
    ],
    num_rounds: 5,
  };
  let mut state = GameState {
    config: &config,
    cur_player: 0,
    public_symbols:  [Vec::new(), Vec::new()],
    private_symbols: [Vec::new(), Vec::new()],
  };
  while !game_done(&state) {
    state = apply_action(state, GameAction {
      public_symbol: modulo(rand::thread_rng().gen::<usize>(), config.num_symbols),
      private_symbol: modulo(rand::thread_rng().gen::<usize>(), config.num_symbols),
    });
    println!("{:?}", state);
  }

  let score = calc_score(&state);
  println!("Final score: {:?}", score);

  match score.cmp(&0) {
    Ordering::Greater => println!("Player 1 wins!"),
    Ordering::Less    => println!("Player 2 wins!"),
    Ordering::Equal   => println!("It is a tie!"),
  }
}
