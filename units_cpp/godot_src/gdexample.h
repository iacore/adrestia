#pragma once
#include <Godot.hpp>
#include <Sprite.hpp>

namespace godot {
  class gdexample : public godot::GodotScript<Script> {
    GODOT_CLASS(gdexample)
   private:
    float time_passed;
   public:
    static void _register_methods();
    gdexample();
    ~gdexample();
    void _process(float delta);
  };
}
