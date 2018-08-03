#include "tech.h"

using namespace godot;

void godot::Tech::_register_methods() {
  register_method((char*)"_process", &godot::Tech::_process);
}

godot::Tech::Tech() {
}

godot::Tech::~Tech() {
}

void godot::Tech::_process(float delta) {
  Godot::print("WAAAH");
}
