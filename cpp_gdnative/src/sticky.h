#pragma once
#include <godot_cpp/godot.hpp>
#include <godot_cpp/classes/gd_script.hpp>
#include <sticky.h>

#include "macros.h"

namespace godot {
	class Effect;
	class EffectInstance;
	class Spell;

	class Sticky : public godot::GDScript, public Forwarder<::Sticky, Sticky> {
			GDCLASS(Sticky, godot::GDScript)
		public:
			static const char *resource_path;
			static void _register_methods();

			Variant get_id() const;
			Variant get_name() const;
			Variant get_text() const;
			Variant get_kind() const;
			Variant get_stacks() const;
			Variant get_effects() const;
			Variant get_trigger_inbound() const;
			bool triggers_for_effect(EffectInstance *effect, bool inbound) const;
			bool triggers_for_spell(Spell *spell) const;
			Variant triggers_at_end_of_turn() const;

			INTF_NULLABLE
			INTF_JSONABLE
	};
}

MAKE_INSTANCEABLE(Sticky)
