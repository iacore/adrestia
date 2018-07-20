#include "resources.h"

using namespace godot;

void godot::Resources::_register_methods() {
  register_method((char*)"_process", &godot::Resources::_process);
}

godot::Resources::Resources() {
}

godot::Resources::~Resources() {
}

void godot::Resources::_process(float delta) {
  Godot::print("WAAAH");
}
