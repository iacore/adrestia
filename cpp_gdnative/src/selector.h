#pragma once
#include <godot_cpp/godot.hpp>
#include <godot_cpp/classes/gd_script.hpp>
#include <selector.h>

#include "macros.h"

namespace godot {
	class Spell;
	class EffectInstance;

	class Selector : public godot::GDScript, public Forwarder<::Selector, Selector> {
			GDCLASS(Selector, godot::GDScript)
		private:
			godot::Ref<godot::NativeScript> Spell_;
			godot::Ref<godot::NativeScript> EffectInstance_;
		public:
			Selector();
			static const char *resource_path;
			static void _register_methods();

			Variant is_valid() const;
			bool selects_spell(Spell *spell) const;
			bool selects_effect(EffectInstance *effect) const;

			INTF_NULLABLE
			INTF_JSONABLE
	};
}

MAKE_INSTANCEABLE(Selector)
