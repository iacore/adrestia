#pragma once
#include <iostream>
#include "json.h"

class Resources {
 public:
  unsigned short red;
  unsigned short green;
  unsigned short blue;

  Resources(unsigned short red, unsigned short green, unsigned short blue);
  void add(const Resources &r);
  void subtract(const Resources &r);
  bool includes(const Resources &r);

  Resources operator+(const Resources &r);
  bool operator<=(const Resources &r);

  friend std::ostream &operator<<(std::ostream &os, const Resources &r);
};

