#pragma once
#include <Godot.hpp>
#include <Reference.hpp>
#include <tech.h>
// TODO jim: <tech.h> is in units_cpp. "tech.h" is this file, which
// serves as an adapter. I think this is a brilliant hack, but it may lead to
// confusion so maybe we should change it.

namespace godot {
  class Tech : public godot::GodotScript<Reference> {
    GODOT_CLASS(Tech)
   public:
    static void _register_methods();
    ::Tech underlying;
    Tech();
    ~Tech();
    void _process(float delta);
  };
}
