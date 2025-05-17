#pragma once
#include <godot_cpp/godot.hpp>
#include <godot_cpp/classes/gd_script.hpp>
#include <sticky_invoker.h>

#include "macros.h"

namespace godot {
	class Duration;

	class StickyInvoker : public godot::GDScript,
			public Forwarder<::StickyInvoker, StickyInvoker> {
			GDCLASS(StickyInvoker, godot::GDScript)
		public:
			static const char *resource_path;
			static void _register_methods();

			Variant get_sticky_id() const;
			Variant get_amount() const;
			Variant get_duration() const;

			INTF_NULLABLE
			INTF_JSONABLE
	};
}

MAKE_INSTANCEABLE(StickyInvoker)
