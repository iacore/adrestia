#pragma once
#include <Godot.hpp>
#include <Reference.hpp>
#include "../../resources.h"

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
