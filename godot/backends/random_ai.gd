extends Object

signal debug_timer

# Private, do not touch
var g = null
var state = null
var ai = null
var started_callback = null
var update_callback = null
var left_game = false

var do_debug_timer = false

# Public
var rules
var forfeited = false

func _init(g_):
	g = g_
	rules = g.get_default_rules()
	ai = g.Strategy.new()
	ai.init_cfr_strategy(rules)

func get_time_limit():
	return 60

func get_view():
	if left_game: return null
	if state == null:
		return null
	var view = g.GameView.new()
	view.init(state, 0)
	return view

func get_state():
	if left_game: return null
	if state == null:
		return null
	if state.winners().size() != 0:
		return state
	else:
		return null

func get_current_move():
	return null

func get_opponent():
	return null

func register_started_callback(callback_):
	started_callback = callback_

func register_update_callback(callback_):
	update_callback = callback_

func emit_debug_timer():
	emit_signal('debug_timer')

func submit_books(selected_book_ids):
	if do_debug_timer:
		var timer = Timer.new()
		timer.set_one_shot(true)
		timer.set_timer_process_callback(0)
		timer.set_wait_time(2.0)
		timer.connect('timeout', Callable(self, 'emit_debug_timer'))
		g.get_node('/root').add_child(timer)
		timer.start()
		await self.debug_timer

	var ai_books = []
	var rules_books = g.get_rules().get_books().keys()
	randomize()
	for i in range(len(rules_books)):
		if i < 3:
			ai_books.append(rules_books[i])
		else:
			var j = randi() % 3
			if j < 3:
				ai_books[j] = rules_books[i]

	if left_game: return
	state = g.GameState.new()
	state.init(g.get_rules(), [selected_book_ids, ai_books])
	if started_callback != null:
		started_callback.call_func()

func submit_action(action):
	if left_game: return false
	if not state.is_valid_action(0, action):
		return false

	var view = g.GameView.new()
	view.init(state, 1)
	var ai_action = ai.get_action(view)

	var events = state.simulate_events([action, ai_action])

	if state.winners().size() > 0:
		var version = g.version_to_string(g.app_version)
		var state_json = state.as_json().result
		if g.network.status == g.network.ONLINE:
			g.network.submit_single_player_game(version, state_json, funcref(g.network, 'print_response'))
		else:
			g.unsubmitted_games.push_back([version, state_json])
			g.save()

	if update_callback != null:
		update_callback.call_func(get_view(), events)

	return true

func leave_game():
	left_game = true
