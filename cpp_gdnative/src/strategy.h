#pragma once
#include <godot_cpp/godot.hpp>
#include <godot_cpp/classes/gd_script.hpp>
#include <strategy.h>
#include <random_strategy.h>
#include <cfr_strategy.h>

#include "macros.h"

namespace godot {
	class Strategy : public godot::GDScript, public Forwarder<::Strategy, Strategy> {
			GDCLASS(Strategy, godot::GDScript)
		public:
			static const char *resource_path;
			static void _register_methods();

			void init_random_strategy();
			void init_cfr_strategy(Variant rules);
			Variant get_action(Variant game_view);

			INTF_NULLABLE
	};
}
