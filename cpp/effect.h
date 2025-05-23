/* Description of a spell effect. Note that this is NOT the same as an
 * instantiation of an effect used during the execution of a turn; see
 * EffectInstance for more details. */

#pragma once

#include "sticky_invoker.h"
#include "effect_kind.h"
#include "effect_type.h"
#include "json.h"

using json = nlohmann::json;

class Effect {
	public:
		Effect();
    ~Effect();
    Effect(const Effect &);
    Effect& operator=(Effect other);
		bool operator==(const Effect &) const;

		EffectKind get_kind() const;
		bool get_targets_self() const;
		EffectType get_effect_type() const;
		int get_amount() const;
		const StickyInvoker &get_sticky_invoker() const;
		const Effect *get_on_hit() const;

		friend void from_json(const json &j, Effect &effect);
		friend void to_json(json &j, const Effect &effect);

	private:
		// Broadly, what sort of thing the effect does.
		EffectKind kind;
		// Whether the effect targets the creator (true) or the other player (false).
		bool targets_self;
		// The type of effect for the purposes of effect classification.
		EffectType effect_type;
		// For EffectKinds other than EK_STICKY, the delta to apply to the
		// corresponding attribute of the target Player.
		int amount;
		// The Sticky that this Effect creates, if any.
		StickyInvoker sticky_invoker;
    // The on-hit effect, if any.
    Effect *on_hit;
};
