#pragma once
#include <godot_cpp/godot.hpp>
#include <godot_cpp/classes/gd_script.hpp>
#include <book.h>

#include "macros.h"

namespace godot {
	class Book : public godot::GDScript, public Forwarder<::Book, Book> {
			GDCLASS(Book, godot::GDScript)
		public:
			static const char *resource_path;
			static void _register_methods();

			Variant get_id() const;
			Variant get_name() const;
			Variant get_spells() const;

			INTF_NULLABLE
			INTF_JSONABLE
	};
}

MAKE_INSTANCEABLE(Book)
