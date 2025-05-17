#pragma once
#include <godot_cpp/godot.hpp>
#include <godot_cpp/classes/gd_script.hpp>
#include <sticky_instance.h>

#include "macros.h"

namespace godot {
	class EffectInstance;
	class Spell;
	class Duration;
	class GameRules;

	class StickyInstance : public godot::GDScript,
			public Forwarder<::StickyInstance, StickyInstance> {
			GDCLASS(StickyInstance, godot::GDScript)
		public:
			static const char *resource_path;
			static void _register_methods();

			void init(GameRules *rules, String json);
			Variant apply_to_effect(int player_id, EffectInstance *effect);
			Variant apply_to_spell(int player_id, Spell *spell);
			Variant apply_to_turn(int player_id);

			INTF_SETGET(int, amount);
			INTF_SETGET(Variant, remaining_duration);
			INTF_SETGET(Variant, spell);
			INTF_SETGET(Variant, sticky);

			INTF_NULLABLE
			INTF_TO_JSONABLE
	};
}

MAKE_INSTANCEABLE(StickyInstance)
