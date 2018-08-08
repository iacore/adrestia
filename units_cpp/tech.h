#pragma once
#include <iostream>
#include "colour.h"
#include "json.h"

using json = nlohmann::json;

class Tech {
 public:
  int red;
  int green;
  int blue;

  Tech();
  Tech(int red, int green, int blue);
  std::string to_string() const;

  void add(const Tech &r);
  void increment(Colour colour);
  bool includes(const Tech &t) const;

  Tech operator+(const Tech &t);

  friend std::ostream &operator<<(std::ostream &os, const Tech &t);
};

void to_json(json &j, const Tech &t);
void from_json(const json &j, Tech &t);
bool operator<=(const Tech &t1, const Tech &t2);
bool operator==(const Tech &t1, const Tech &t2);
