#include <iostream>
#include "resources.h"
#include "json.h"

Resources::Resources(unsigned short red, unsigned short green, unsigned short blue)
  : red(red), green(green), blue(blue) {
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
  os << "(Resources " << r.red << " " << r.green << " " << r.blue << ")";
  return os;
}
