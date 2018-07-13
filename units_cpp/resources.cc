#include <iostream>
#include "resources.h"
#include "json.h"

Resources::Resources() : red(0), green(0), blue(0) {}
Resources::Resources(unsigned short red, unsigned short green, unsigned short blue)
  : red(red), green(green), blue(blue) {
}

void from_json(const json &j, Resources &r) {
  r.red = j.find("red") != j.end() ? j["red"].get<unsigned short>() : 0;
  r.green = j.find("green") != j.end() ? j["green"].get<unsigned short>() : 0;
  r.blue = j.find("blue") != j.end() ? j["blue"].get<unsigned short>() : 0;
}

void to_json(json &j, const Resources &r) {
  if (r.red) j["red"] = r.red;
  if (r.green) j["green"] = r.green;
  if (r.blue) j["blue"] = r.blue;
}

void Resources::add(const Resources &r) {
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
  red -= r.red;
  green -= r.green;
  blue -= r.blue;
}

bool Resources::includes(const Resources &r) {
  return (
      red >= r.red &&
      green >= r.green &&
      blue >= r.blue
  );
}

bool Resources::operator<=(const Resources &r) {
  return this->includes(r);
}

std::ostream &operator<<(std::ostream &os, const Resources &r) {
  os << json(r);
  return os;
}
