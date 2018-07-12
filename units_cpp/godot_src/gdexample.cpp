#include "gdexample.h"

using namespace godot;

void gdexample::_register_methods() {
  register_method((char*)"_process", &gdexample::_process);
}

gdexample::gdexample() {
  time_passed = 0.0;
}

gdexample::~gdexample() {
}

void gdexample::_process(float delta) {
  time_passed += delta;
}
