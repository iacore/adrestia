#pragma once
#include <godot_cpp/godot.hpp>
#include "godot_cpp/classes/gd_script.hpp"
#include <duration.h>

#include "macros.h"

namespace godot {
	class Duration : public godot::GDScript, public Forwarder<::Duration, Duration> {
			GDCLASS(Duration, godot::GDScript)
		public:
			static const char *resource_path;
			static void _register_methods();

			Variant is_active() const;
			Variant get_unit() const;
			Variant get_value() const;

			void subtract_step();
			void subtract_turn();
			void set_to_zero();

			INTF_NULLABLE
			INTF_JSONABLE
	};
}

MAKE_INSTANCEABLE(Duration)
