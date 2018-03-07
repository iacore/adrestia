extern crate rand;
extern crate num;
use rand::Rng;

fn modulo<T: num::integer::Integer + Copy>(x: T, m: T) -> T {
  ((x % m) + m) % m
}

fn pick_symbol() -> usize {
  modulo(rand::thread_rng().gen::<usize>(), 3)
}

fn calc_score(p1: &Vec<usize>, p2: &Vec<usize>, payoffs: &[[i32; 3]; 3]) -> i32 {
  let mut score = 0;
  for s in p1 {
    for t in p2 {
      score += payoffs[*s][*t];
    }
  }
  score
}

fn main() {
  let payoffs = [
    [0, 1, -1],
    [-1, 0, 1],
    [1, -1, 0],
  ];
  let num_rounds = 10;
  let players: Vec<Vec<usize>> = (0..2).map(|_| {
    (0..num_rounds).map(|_| { pick_symbol() }).collect()
  }).collect();

  print!("{:?}\n", players);

  let score = calc_score(&players[0], &players[1], &payoffs);
  print!("{:?}\n", score);

  if score > 0 {
    print!("Player 1 wins!");
  } else if score < 0 {
    print!("Player 2 wins!");
  } else {
    print!("It is a tie!");
  }
}
