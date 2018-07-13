#pragma once
#include <vector>
#include "colour.h"
#include "resources.h"
#include "json.h"

using json = nlohmann::json;

class UnitKind {
 public:
  UnitKind();
  ~UnitKind();
  std::string get_name() const;
  Colour get_colour() const;
  unsigned short get_health() const;
  unsigned short get_shields() const;
  unsigned short get_width() const;
  unsigned short get_build_time() const;
  const std::vector<unsigned short> get_attack() const;
  const Resources *get_cost() const;
  const Resources *get_font() const;
  std::string get_image() const;
  const std::vector<unsigned short> get_tiles() const;
  char get_label() const;

  friend void to_json(json &j, const UnitKind &kind);
  friend void from_json(const json &j, UnitKind &kind);
 private:
  std::string name;
  Colour colour;
  unsigned short health;
  unsigned short shields;
  unsigned short width;
  unsigned short build_time;
  std::vector<unsigned short> attack;
  Resources *cost; // nullptr for no cost
  Resources *font; // nullptr for no font behaviour
  std::string image;
  std::vector<unsigned short> tiles;
  char label;
};

