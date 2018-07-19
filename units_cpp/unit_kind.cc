#include "unit_kind.h"
#include <iostream>
#include <array>

UnitKind::UnitKind() {}
UnitKind::~UnitKind() {
  if (cost != nullptr) delete cost;
  if (font != nullptr) delete font;
}

void from_json(const json &j, UnitKind &kind) {
  kind.id = j["id"];
  kind.name = j["name"];
  kind.colour = j["colour"].get<Colour>();
  kind.health = j["health"];
  kind.shields = j.find("shields") != j.end() ? (int)j["shields"] : 0;
  kind.width = j["width"];
  kind.build_time = j.find("build_time") != j.end() ? (int)j["build_time"] : 0;
  kind.attack = std::vector<int>();
  for (int i = 0; i < j["attack"].size(); i++) {
    kind.attack.push_back(j["attack"][i]);
  }
  kind.cost = !j["cost"].is_null() ? new Resources(j["cost"]) : nullptr;
  kind.font = j.find("font") != j.end() ? new Resources(j["font"]) : nullptr;
  kind.image = j["image"];
  kind.tiles = std::vector<int>();
  for (int i = 0; i < j["tiles"].size(); i++) {
    kind.tiles.push_back(j["tiles"][i]);
  }
  kind.label = j["label"].get<std::string>()[0];
}

void to_json(json &j, const UnitKind &kind) {
  j["id"] = kind.id;
  j["name"] = kind.name;
  j["colour"] = kind.colour;
  j["health"] = kind.health;
  if (kind.shields > 0) j["shields"] = kind.shields;
  j["width"] = kind.width;
  if (kind.build_time > 0) j["build_time"] = kind.build_time;
  j["attack"] = kind.attack;
  if (kind.cost != nullptr) {
    j["cost"] = *kind.cost;
  } else {
    j["cost"] = nullptr;
  }
  if (kind.font != nullptr) j["font"] = *kind.font;
  j["image"] = kind.image;
  j["tiles"] = kind.tiles;
  j["label"] = std::string(1, kind.label);
}

std::string UnitKind::get_id() const {
  return id;
}

std::string UnitKind::get_name() const {
  return name;
}

Colour UnitKind::get_colour() const {
  return colour;
}

int UnitKind::get_health() const {
  return health;
}

int UnitKind::get_shields() const {
  return shields;
}

int UnitKind::get_width() const {
  return width;
}

int UnitKind::get_build_time() const {
  return build_time;
}

const std::vector<int> UnitKind::get_attack() const {
  return attack;
}

const Resources *UnitKind::get_cost() const {
  return cost;
}

const Resources *UnitKind::get_font() const {
  return font;
}

std::string UnitKind::get_image() const {
  return image;
}

const std::vector<int> UnitKind::get_tiles() const {
  return tiles;
}

char UnitKind::get_label() const {
  return label;
}
