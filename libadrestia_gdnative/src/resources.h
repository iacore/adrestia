#pragma once
#include <Godot.hpp>
#include <Reference.hpp>
#include <resources.h>
// TODO jim: <resources.h> is in units_cpp. "resources.h" is this file, which
// serves as an adapter. I think this is a brilliant hack, but it may lead to
// confusion so maybe we should change it.

namespace godot {
  class Resources : public godot::GodotScript<Reference> {
    GODOT_CLASS(Resources)
   public:
    static void _register_methods();
    ::Resources underlying;
    Resources();
    ~Resources();
    void _process(float delta);
  };
}
