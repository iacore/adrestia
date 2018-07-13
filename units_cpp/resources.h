#pragma once
#include <iostream>
#include "json.h"

using json = nlohmann::json;

class Resources {
 public:
  unsigned short red;
  unsigned short green;
  unsigned short blue;

  Resources();
  Resources(unsigned short red, unsigned short green, unsigned short blue);
  void add(const Resources &r);
  void subtract(const Resources &r);
  bool includes(const Resources &r);

  Resources operator+(const Resources &r);
  bool operator<=(const Resources &r);

  friend void to_json(json &j, const Resources &r);
  friend void from_json(const json &j, Resources &r);
  friend std::ostream &operator<<(std::ostream &os, const Resources &r);
};

