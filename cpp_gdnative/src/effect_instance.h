#pragma once
#include <godot_cpp/godot.hpp>
#include <godot_cpp/classes/gd_script.hpp>
#include <effect_instance.h>

#include "macros.h"

namespace godot {
	class GameRules;
	class Player;

	class EffectInstance : public godot::GDScript, public Forwarder<::EffectInstance, EffectInstance> {
			GDCLASS(EffectInstance, godot::GDScript)
		public:
			static const char *resource_path;
			static void _register_methods();

			void apply(GameRules *rules, Player *player) const;

			INTF_SETGET(int, kind)
			INTF_SETGET(bool, targets_self)
			INTF_SETGET(int, effect_type)
			INTF_SETGET(int, amount)
			INTF_SETGET(Variant, sticky_invoker)
			INTF_SETGET(Variant, spell)
			INTF_SETGET(int, target_player)

			INTF_NULLABLE
			INTF_TO_JSONABLE
	};
}

MAKE_INSTANCEABLE(EffectInstance)
