#pragma once
#include <godot.hpp>
#include <Reference.hpp>
#include <selector.h>

#include "macros.h"

namespace godot {
	class Spell;
	class EffectInstance;

	class Selector : public godot::GodotScript<Reference>, public Forwarder<::Selector, Selector> {
			GODOT_CLASS(Selector)
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
