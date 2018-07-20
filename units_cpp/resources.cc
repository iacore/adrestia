#include <iostream>
#include "resources.h"
#include "json.h"

Resources::Resources() : coins(0), red(0), green(0), blue(0) {}
Resources::Resources(int coins, int red, int green, int blue)
  : coins(coins), red(red), green(green), blue(blue) {
}

void from_json(const json &j, Resources &r) {
  r.coins = j.find("coins") != j.end() ? j["coins"].get<int>() : 0;
  r.red = j.find("red") != j.end() ? j["red"].get<int>() : 0;
  r.green = j.find("green") != j.end() ? j["green"].get<int>() : 0;
  r.blue = j.find("blue") != j.end() ? j["blue"].get<int>() : 0;
}

void to_json(json &j, const Resources &r) {
  if (r.coins) j["coins"] = r.coins;
  if (r.red) j["red"] = r.red;
  if (r.green) j["green"] = r.green;
  if (r.blue) j["blue"] = r.blue;
}

void Resources::add(const Resources &r) {
  coins += r.coins;
  red += r.red;
  green += r.green;
  blue += r.blue;
}

Resources Resources::operator+(const Resources &r) {
  Resources result(*this);
  result.add(r);
  return result;
}

void Resources::subtract(const Resources &r) {
  coins -= r.coins;
  red -= r.red;
  green -= r.green;
  blue -= r.blue;
}

bool Resources::includes(const Resources &r) const {
  return (
      coins >= r.coins &&
      red >= r.red &&
      green >= r.green &&
      blue >= r.blue
  );
}

bool operator<=(const Resources &r1, const Resources &r2) {
  return r2.includes(r1);
}

std::ostream &operator<<(std::ostream &os, const Resources &r) {
  os << json(r);
  return os;
}

bool operator==(const Resources &a, const Resources &b) {
  return (
      a.coins == b.coins &&
      a.red == b.red &&
      a.green == b.green &&
      a.blue == b.blue
  );
}
