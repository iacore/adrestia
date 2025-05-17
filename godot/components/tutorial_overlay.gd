extends Control

signal node_found(node)
signal popup_closed()

@onready var g = get_node('/root/global')

@onready var mouse_blocker = $mouse_blocker
@onready var big_text_wnd = $nine_patch_rect
@onready var tree_poll_timer = $tree_poll_timer
@onready var big_text = $nine_patch_rect/margin_container/rich_text_label

var finished_first_turn = false
var open_time = 0

func _ready():
	mouse_blocker.connect('gui_input', Callable(self, 'blocker_input'))
	tree_poll_timer.connect('timeout', Callable(self, 'timeout'))
	big_text_wnd.visible = false
	mouse_blocker.visible = false

func close_blocker():
	if Time.get_ticks_msec() - open_time < 500:
		return
	if force_click_rect != null && !force_click_rect.has_point(get_viewport().get_mouse_position()):
		return
	force_click_rect = null
	big_text_wnd.visible = false
	mouse_blocker.visible = false
	g.close_tooltip()
	emit_signal('popup_closed')

var force_click_rect = null
func blocker_input(event):
	if g.event_is_pressed(event):
		close_blocker()

func _input(event):
	if mouse_blocker.mouse_filter == MOUSE_FILTER_IGNORE:
		if g.event_is_pressed(event):
			if force_click_rect != null && !force_click_rect.has_point(get_viewport().get_mouse_position()):
				get_viewport().set_input_as_handled()
			else:
				close_blocker()

func try_get_node(path):
	var node = get_node('/root/scene_loader')
	if node == null: return
	node = node.get_child(0);
	if node == null: return
	node = node.get_child(0);
	if node == null: return
	if path != '':
		node = node.get_node(path);
		if node == null: return
		return node
	else:
		return node

var desire_path = null
func timeout():
	if desire_path == null: return
	var node = try_get_node(desire_path)
	if node == null: return
	# jim: We don't set desire_path back to null here just in case and a timeout
	# happens such that the yield misses the emit. (are godot classes monitors?)
	emit_signal('node_found', node)

func acquire_node(path):
	await get_tree().idle_frame
	# Try to get the node immediately for efficiency
	var node = try_get_node(path)
	if node != null:
		return node
	# If not found, poll for it
	desire_path = path
	node = await self.node_found
	desire_path = null
	return node

# Spotlight tweening
var old_spotlight_pos
var old_spotlight_size
var new_spotlight_pos
var new_spotlight_size
var tween_start_time
var tween_end_time

func _process(delta):
	if tween_start_time == null:
		set_process(false)
		return
	var cur_time = float(Time.get_ticks_msec())
	var completion = pow(min(1.0, (cur_time - tween_start_time) / (tween_end_time - tween_start_time)), 0.3)
	var spotlight_pos  = new_spotlight_pos  * completion + old_spotlight_pos  * (1.0 - completion)
	var spotlight_size = new_spotlight_size * completion + old_spotlight_size * (1.0 - completion)
	mouse_blocker.material.set_shader_parameter('radius', 10.0);
	mouse_blocker.material.set_shader_parameter('position', spotlight_pos);
	mouse_blocker.material.set_shader_parameter('size', spotlight_size);
	if completion >= 1.0:
		tween_start_time = null
		set_process(false)

func tween_spotlight_to(pos, size):
	tween_start_time = float(Time.get_ticks_msec())
	tween_end_time = float(Time.get_ticks_msec()) + 350.0
	old_spotlight_pos = new_spotlight_pos
	if not old_spotlight_pos: old_spotlight_pos = get_viewport_rect().size / 2.0
	old_spotlight_size = new_spotlight_size
	if not old_spotlight_size: old_spotlight_size = get_viewport_rect().size
	new_spotlight_pos = pos
	new_spotlight_size = size
	set_process(true)

func show_big_window(text):
	open_time = Time.get_ticks_msec()
	big_text.text = text
	mouse_blocker.visible = true
	mouse_blocker.material.set_shader_parameter('radius', 0.0);
	big_text_wnd.visible = true
	await self.popup_closed

func show_tooltip(target, text, force=false):
	open_time = Time.get_ticks_msec()
	var rect = target.get_global_rect()
	mouse_blocker.visible = true
	if force:
		force_click_rect = rect
	tween_spotlight_to(rect.position + (rect.size / 2.0), rect.size / 2.0)
	await g.summon_tooltip(target, text).completed
	if g.tooltip:
		g.tooltip.mouse_filter = MOUSE_FILTER_IGNORE
	await self.popup_closed

func play_button_pressed_override(select_root):
	# Check that book list contains Conjuration
	var has_bloodlust = false
	var has_regulation = false
	for book in select_root.chosen_books:
		if book == null: continue
		if book.get_id() == 'bloodlust': has_bloodlust = true
		if book.get_id() == 'regulation': has_regulation = true
	if has_bloodlust and has_regulation:
		select_root.on_play_button_pressed()
	else:
		show_big_window('You need to select the [color=#DC0000][b]Book of Bloodlust[/b][/color] and the [color=#2AA696][b]Book of Frost[/b][/color] for this tutorial.')

func end_turn_button_pressed_override(game_root):
	var view = g.backend.get_view()
	if view == null:
		game_root.on_end_turn_button_pressed()
		return
	var turn = view.turn_number()
	var spells = game_root.my_spell_list.spells
	if turn == 1 and spells != ['regulation_tech', 'regulation_1']:
		show_big_window('For this turn, just learn [color=#00ADBA][b]Frost Shield[/b][/color] from the [color=#2AA696][b]Book of Frost[/b][/color], then cast it.')
	elif turn == 2 and spells != ['regulation_1', 'regulation_tech', 'regulation_2']:
		#show_big_window('For this turn:\n- Cast [b]Frost Shield[/b]\n- Then, learn [color=#05ACB8][b]Iceberg[/b][/color]\n- Finally, cast [color=#05ACB8][b]Iceberg[/b][/color].\nOrder is important!')
		pass
	elif turn == 3 and spells != ['bloodlust_tech', 'bloodlust_1', 'bloodlust_1']:
		show_big_window('For this turn, learn [color=#FF4C2B][b]Razor Wind[/b][/color], then cast it twice.')
	else:
		game_root.on_end_turn_button_pressed()
		return

func should_long_press_button_override():
	show_big_window('Long-press the [color=#05ACB8][b]Iceberg[/b][/color] spell by holding down for a moment after you tap it.')

func play_tutorial():
	g.tooltip_min_open_time = 500
	# Book Select
	var selected_books_hbox = await self.acquire_node('ui/selected_books_hbox').completed
	var select_root = await self.acquire_node('').completed
	var play_button = await self.acquire_node('ui/play_button').completed

	# Set up Play button override
	g.safe_disconnect(play_button, 'pressed', select_root, 'on_play_button_pressed')
	play_button.connect('pressed', Callable(self, 'play_button_pressed_override').bind(select_root))

	# Show information
	await show_big_window("[b]Welcome to [color=#F74F01]Adrestia[/color]![/b]\n\nYour objective is to use your spells and your wit to defeat your enemy.").completed
	var books_hbox = await self.acquire_node('ui/books_scroll/books_hbox').completed
	var book_bloodlust_button = books_hbox.get_child(0)
	var book_frost_button = books_hbox.get_child(4)
	await show_tooltip(book_bloodlust_button.get_child(0), 'Tap the [color=#DC0000][b]Book of Bloodlust[/b][/color] to see what spells it contains.', true).completed
	select_root.show_book_detail(book_bloodlust_button.book)

	var spell_preview = await self.acquire_node('ui/spell_button_list').completed
	await show_tooltip(spell_preview, 'Each book has four spells.').completed
	var spell_button = spell_preview.get_child(1).get_child(1)
	await show_tooltip(spell_button, 'Tap the [color=#DC0000][b]Frenzy[/b][/color] spell to see what it does.', true).completed
	spell_button.on_long_press()
	await g.tooltip_closed
	var mana_indicator = spell_button.get_node('ui/cost/mp_icon')
	await show_tooltip(mana_indicator, "The spell's mana cost is shown in this corner.").completed

	var book_slots = await self.acquire_node('ui/selected_books_hbox').completed
	await show_big_window("For this tutorial, we will use two books:\nthe [color=#DC0000][b]Book of Bloodlust[/b][/color] and the [color=#2AA696][b]Book of Frost[/b][/color].").completed
	mouse_blocker.mouse_filter = MOUSE_FILTER_IGNORE
	select_root.forced_book = 'bloodlust'
	await show_tooltip(book_bloodlust_button, 'The [color=#DC0000][b]Book of Bloodlust[/b][/color] is an aggressive book that focuses on dealing damage. Drag it up to select it.').completed
	await select_root.chose_book

	# If not already visible on screen, wait for scroll to frost book.
	var showed_scroll_tooltip = false
	var book_frost_last_x = 0.0
	var still_checks = 0
	while true:
		var book_frost_rect = book_frost_button.get_global_rect()
		if book_frost_last_x != book_frost_rect.position.x:
			still_checks = 0
			book_frost_last_x = book_frost_rect.position.x
		if book_frost_last_x >= 40 and book_frost_last_x <= get_viewport_rect().size.x - book_frost_rect.size.x - 40:
			if still_checks >= 2 or not showed_scroll_tooltip:
				break
			still_checks += 1
		if not showed_scroll_tooltip:
			await show_tooltip(books_hbox, 'Now scroll to the right until you see the [color=#2AA696][b]Book of Frost[/b][/color].').completed
			showed_scroll_tooltip = true
		await tree_poll_timer.timeout
	mouse_blocker.mouse_filter = MOUSE_FILTER_STOP

	select_root.forced_book = 'regulation'
	yield(show_tooltip(book_frost_button,
		'The [color=#2AA696][b]Book of Frost[/b][/color] is a good book for defense. Tap it to see its spells, then drag it up to select it.', true), 'completed')
	select_root.show_book_detail(book_frost_button.book)
	if not select_root.has_selected_book('regulation'):
		await select_root.chose_book
	select_root.forced_book = null
	yield(show_tooltip(play_button,
		"Good job! The third book is yours to choose. When you're done, press the [b]Done[/b] button to fight against an AI opponent."), 'completed')

	# Game
	g.tooltip_min_open_time = 0
	var spell_select = await self.acquire_node('ui/spell_select').completed
	var game_root = await self.acquire_node('').completed
	var end_turn_button = await self.acquire_node('ui/end_turn_button').completed
	# Override end turn button
	g.safe_disconnect(end_turn_button, 'pressed', game_root, 'on_end_turn_button_pressed')
	end_turn_button.connect('pressed', Callable(self, 'end_turn_button_pressed_override').bind(game_root))
	# Show information
	yield(show_big_window(
		'Nice work! Let\'s take a look around the game screen.\n\n[i]Tap to continue[/i]'), 'completed')
	var my_stats = await self.acquire_node('ui/my_avatar').completed
	yield(show_tooltip(my_stats,
		'This is you! You have [color=#FF054B][b]40[/b][/color] health and [color=#458BFF][b]3[/b][/color] mana. The [color=#458BFF][b]+3[/b][/color] beside your mana shows your mana regeneration; you\'ll get this much mana at the start of each turn.'), 'completed')

	var book_btn_bloodlust = null
	var book_btn_frost = null
	var book_btn_frost_i = null
	for i in range(len(spell_select.books)):
		if spell_select.books[i].get_id() == 'bloodlust':
			book_btn_bloodlust = spell_select.get_node('book_buttons').get_child(i)
		if spell_select.books[i].get_id() == 'regulation':
			book_btn_frost = spell_select.get_node('book_buttons').get_child(i)
			book_btn_frost_i = i

	# Turn 1
	await show_tooltip(book_btn_frost, 'Tap the [color=#2AA696][b]Book of Frost[/b][/color] to open it up.', true).completed
	book_btn_frost.get_node('book').emit_signal('pressed')
	var spell_select_animator = spell_select.get_node('animation_player')
	await spell_select_animator.animation_finished
	var buy_spell_buttons = spell_select.get_node('spell_panel/ninepatch/hbox')
	yield(show_tooltip(buy_spell_buttons,
		'Notice that all the spells are locked. You haven\'t learned any of them yet.'), 'completed')
	yield(show_tooltip(buy_spell_buttons,
		'You learn spells from left to right, and only one per turn.'), 'completed')
	yield(show_tooltip(buy_spell_buttons.get_child(0),
		'Learn [color=#00ADBA][b]Frost Shield[/b][/color] by tapping on the blue lock.', true), 'completed')
	buy_spell_buttons.get_child(0).emit_signal('pressed')
	yield(show_tooltip(buy_spell_buttons.get_child(0),
		'Now, tap [color=#00ADBA][b]Frost Shield[/b][/color] to cast it.', true), 'completed')
	buy_spell_buttons.get_child(0).emit_signal('pressed')
	var close_book_button = spell_select.get_node('spell_panel/ninepatch/close_button')
	yield(show_tooltip(close_book_button,
		'Close the book...', true), 'completed')
	close_book_button.emit_signal('pressed')
	yield(show_tooltip(end_turn_button,
		'Use the [b]Commit[/b] button to commit to your spell selection and cast your spells. Tap it now.', true), 'completed')
	end_turn_button.emit_signal('pressed')

	# Turn 1 animation
	var spell_animation_area = game_root.get_node('ui/spell_animation_area')
	game_root.animate_events = false
	yield(show_tooltip(spell_animation_area,
		'Your spells happen at the same time as your opponent\'s.\n[i]Tap to continue[/i]'), 'completed')
	yield(show_tooltip(spell_animation_area,
		'Your enemy tried to damage you with [color=#FF4C2B][b]Razor Wind[/b][/color], but you will block it just in time with your [color=#00ADBA][b]Frost Shield[/b][/color].\n[i]Tap to continue[/i]'), 'completed')
	game_root.animate_events = true
	await game_root.turn_animation_finished
	finished_first_turn = true
	close_blocker()

	# Turn 2
	yield(show_big_window(
		"A second [color=#FF4C2B][b]Razor Wind[/b][/color] would have broken through your shield. Let's get a stronger defense."), 'completed')
	yield(show_tooltip(book_btn_frost,
		'Open up the [color=#2AA696][b]Book of Frost[/b][/color] again.', true), 'completed')
	book_btn_frost.get_node('book').emit_signal('pressed')
	await spell_select_animator.animation_finished
	mouse_blocker.mouse_filter = MOUSE_FILTER_IGNORE
	game_root.can_cast_spells = false
	show_tooltip(buy_spell_buttons.get_child(1),
		"Let's see what [color=#05ACB8][b]Iceberg[/b][/color] does. Long-press the spell to see its description.", true)
	await g.tooltip_closed # for the tutorial tooltip
	mouse_blocker.mouse_filter = MOUSE_FILTER_STOP
	buy_spell_buttons.get_child(1).texture_button.connect('pressed', Callable(self, 'should_long_press_button_override'))
	while true:
		# for the spell detail view
		var content = await g.tooltip_closed
		if 'Iceberg' in content:
			break
		else:
			spell_select.on_open_book(book_btn_frost_i, spell_select.books[book_btn_frost_i])
			should_long_press_button_override()
	buy_spell_buttons.get_child(1).texture_button.disconnect('pressed', Callable(self, 'should_long_press_button_override'))
	game_root.can_cast_spells = true
	yield(show_tooltip(buy_spell_buttons.get_child(1),
		"[color=#05ACB8][b]Iceberg[/b][/color] is a powerful shield. But let's not learn it yet."), 'completed')
	yield(show_tooltip(buy_spell_buttons.get_child(0),
		"You can get attacked while learning a spell. Let's cast [color=#00ADBA][b]Frost Shield[/b][/color] first, just in case.", true), 'completed')
	buy_spell_buttons.get_child(0).emit_signal('pressed')
	yield(show_tooltip(buy_spell_buttons.get_child(1),
		"Since [color=#05ACB8][b]Iceberg[/b][/color] lasts for two turns, you can use it to defend yourself next turn. Tap the blue lock to learn it.", true), 'completed')
	buy_spell_buttons.get_child(1).emit_signal('pressed')
	yield(show_tooltip(buy_spell_buttons.get_child(1),
		"Tap [color=#05ACB8][b]Iceberg[/b][/color] to cast it.", true), 'completed')
	buy_spell_buttons.get_child(1).emit_signal('pressed')
	yield(show_tooltip(close_book_button,
		'Close the book...', true), 'completed')
	close_book_button.emit_signal('pressed')
	yield(show_tooltip(end_turn_button,
		'Tap [b]Commit[/b] to advance the turn.', true), 'completed')
	end_turn_button.emit_signal('pressed')

	# Turn 2 animation
	game_root.animate_events = false
	yield(show_tooltip(spell_animation_area,
		'Nicely done. Your [color=#00ADBA][b]Frost Shield[/b][/color] will block the first [color=#FF4C2B][b]Razor Wind[/b][/color] while your [color=#05ACB8][b]Iceberg[/b][/color] will block the second one.\n[i]Tap to continue[/i]'), 'completed')
	game_root.animate_events = true
	await game_root.turn_animation_finished
	close_blocker()

	# Turn 3
	var sticky_display = game_root.get_node('ui/my_stickies/grid').get_child(0)
	yield(show_tooltip(sticky_display.get_node('texture'),
		'Many spells leave effects that last multiple turns. Iceberg gives you a shield. Tap this effect to see a description.', true), 'completed')
	sticky_display = game_root.get_node('ui/my_stickies/grid').get_child(0)
	g.summon_sticky_tooltip(sticky_display, sticky_display.sticky)
	await g.tooltip_closed
	yield(show_tooltip(book_btn_bloodlust,
		'With a strong shield already up, we can focus on the attack. Open up the [color=#DC0000][b]Book of Bloodlust[/b][/color].', true), 'completed')
	book_btn_bloodlust.get_node('book').emit_signal('pressed')
	await spell_select_animator.animation_finished
	yield(show_tooltip(buy_spell_buttons.get_child(0),
		"[color=#FF4C2B][b]Razor Wind[/b][/color] is the same spell your opponent tried to damage you with. Learn it now.", true), 'completed')
	buy_spell_buttons.get_child(0).emit_signal('pressed')
	yield(show_tooltip(buy_spell_buttons.get_child(0),
		"Tap [color=#FF4C2B][b]Razor Wind[/b][/color] to cast it.", true), 'completed')
	buy_spell_buttons.get_child(0).emit_signal('pressed')
	yield(show_tooltip(buy_spell_buttons.get_child(0),
		"Let’s bring the pain! Cast [color=#FF4C2B][b]Razor Wind[/b][/color] again.", true), 'completed')
	buy_spell_buttons.get_child(0).emit_signal('pressed')
	yield(show_tooltip(close_book_button,
		'Though you still have mana, you can only cast three spells at a time. Close the book.', true), 'completed')
	close_book_button.emit_signal('pressed')
	yield(show_tooltip(end_turn_button,
		'Commit your selection.', true), 'completed')
	end_turn_button.emit_signal('pressed')

	# Turn 3 animation
	game_root.animate_events = false
	yield(show_tooltip(spell_animation_area,
		'You are protected by your [color=#05ACB8][b]Iceberg[/b][/color] from last turn, but your own [color=#FF4C2B][b]Razor Wind[/b][/color]s will hit the enemy! Nice!\n[i]Tap to continue[/i]'), 'completed')
	game_root.animate_events = true
	await game_root.turn_animation_finished
	close_blocker()

	# Turn 4
	yield(show_tooltip(my_stats.get_node('mana_box'),
		'Leftover mana carries over between turns. Since you had 3 left from last turn, it plus your 3 mana regen gives you 6 now.'), 'completed')
	yield(show_big_window(
		"One final tip: many spells have an [b]on hit[/b] effect that triggers when they get through shields. Staying shielded can save you from a lot of pain."), 'completed')

	await show_big_window("You're on your own now! Good luck.").completed

	# Results
	var results_text = await self.acquire_node('ui/results_text').completed
	var results_root = await self.acquire_node('').completed
	if results_root.winner == 0:
		await show_big_window('Nice job! You\'re ready to test your skills against a real opponent.').completed
	else:
		await show_big_window('Looks like you didn\'t win. Maybe you should try the tutorial again.').completed

	# Clean self up
	self.get_parent().remove_child(self)
