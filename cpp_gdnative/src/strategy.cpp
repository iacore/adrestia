#include "strategy.h"

#include "game_rules.h"
#include "game_action.h"
#include "game_view.h"

#define CLASSNAME Strategy

using namespace godot;

namespace godot {
	SCRIPT_AT("res://native/strategy.gdns")

	void CLASSNAME::_register_methods() {
		REGISTER_METHOD(init_random_strategy)
		REGISTER_METHOD(init_cfr_strategy)
		REGISTER_METHOD(get_action)
		REGISTER_NULLABLE
	}

	void CLASSNAME::init_random_strategy() {
		set_ptr(new ::RandomStrategy());
	}

	void CLASSNAME::init_cfr_strategy(Variant rules) {
		auto *_rules = dynamic_cast<GameRules*>(rules);
		set_ptr(new ::CfrStrategy(*_rules->_ptr));
	}

	Variant CLASSNAME::get_action(Variant view) {
		auto *_view = dynamic_cast<GameView*>(view);
		return to_godot_variant(_ptr->get_action(*_view->_ptr));
	}

	IMPL_NULLABLE
}
