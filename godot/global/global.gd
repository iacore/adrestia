extends Node

const Book = preload('res://native/book.gdns')
const Duration = preload('res://native/duration.gdns')
const DurationUnit = preload('res://native/duration_unit.gd')
const StickyInvoker = preload('res://native/sticky_invoker.gdns')
const Effect = preload('res://native/effect.gdns')
const EffectKind = preload('res://native/effect_kind.gd')
const Spell = preload('res://native/spell.gdns')
const EffectType = preload('res://native/effect_type.gd')
const Sticky = preload('res://native/sticky.gdns')
const GameRules = preload('res://native/game_rules.gdns')
const GameState = preload('res://native/game_state.gdns')
const GameView = preload('res://native/game_view.gdns')
const Strategy = preload('res://native/strategy.gdns')

const Tweener = preload('res://global/tweener.gd')

signal tooltip_closed(content)

@onready var tooltip_scene = preload('res://components/tooltip.tscn')
@onready var spell_button_scene = preload('res://components/spell_button.tscn')
@onready var delta_anim_scene = preload('res://components/delta_anim.tscn')
@onready var confirm_popup_scene = preload('res://components/confirm_popup.tscn')
@onready var text_entry_popup_scene = preload('res://components/text_entry_popup.tscn')

@onready var scene_loader = get_node('/root/scene_loader')
@onready var network = get_node('/root/networking')
@onready var drag_drop = get_node('/root/drag_drop')
@onready var sound = get_node('/root/sound')

# Read from rules.json
var app_version = null # e.g. [1, 0, 0]

var loaded = false
var backend = null
var tutorial_overlay = null
var tooltip = null # Currently displayed tooltip

# jim: So, why the hell is this an array? Because we have to keep all versions
# of the rules we've ever conceivably used alive, and it's hard to keep track
# of exactly when we can be sure that rules can be freed, so we just never free
# them. The .back() of this array will be the freshest rules, and backends can
# override these rules (as retrieved by [get_rules]). But the rules must always
# live.
var rules = []

func _ready():
	pass

func get_rules():
	if backend == null:
		return rules.back()
	return backend.rules

func get_default_rules():
	return rules.back()

func update_rules(json_string):
	var new_rules = GameRules.new()
	new_rules.load_json_string(json_string)
	rules.append(new_rules)
	save()

static func sum(list):
	var result = 0
	for elem in list:
		result += elem
	return result

static func clear_children(node):
	for i in range(0, node.get_child_count()):
		node.get_child(i).queue_free()

# Gets child by name rather than index.
static func child(parent, child_name):
	# Not recursive; not owned.
	return parent.find_child(child_name, false, false)

static func map_method(list, method):
	var result = []
	for elem in list:
		result.append(elem.call(method))
	return result

static func map_member(list, member):
	var result = []
	for elem in list:
		result.append(elem.get(member))
	return result

static func filter(list, predicate):
	var result = []
	for elem in list:
		if predicate.call_func(elem):
			result.append(elem)
	return result

static func dispose(node):
	node.queue_free()

static func load_or(path, path_default):
	# jim: This spits errors into the debugger but is necessary to have custom
	# art show in Android. https://github.com/godotengine/godot/issues/8773
	# jim: Actually, this is a good thing since it lets us know exactly which
	# things still need assets and annoys us until we create them.
	var thing = load(path)
	if thing == null:
		thing = load(path_default)
	return thing

static func get_thing_texture(thing_type, thing_id):
	return load_or(
		'res://art-built/%s/%s.png' % [thing_type, thing_id],
		'res://art-built/%s/placeholder.png' % thing_type)

static func get_book_texture(book_id):
	return get_thing_texture("book", book_id)

static func get_spell_texture(spell_id):
	return get_thing_texture("spells", spell_id)

static func get_sticky_texture(sticky_id):
	return get_thing_texture("stickies", sticky_id)

func make_spell_buttons(spells, show_stats = false, appear_anim = false,
		enabled_filter = null, unlocked_filter = null, unlockable_filter = null):
	var result = []
	for spell_id in spells:
		var spell = get_rules().get_spell(spell_id)
		result.append(spell_button_scene.instantiate())
	update_spell_buttons(result, spells, show_stats, appear_anim, enabled_filter, unlocked_filter, unlockable_filter)
	return result

func update_spell_buttons(buttons, spells, show_stats = false, appear_anim = false,
		enabled_filter = null, unlocked_filter = null, unlockable_filter = null):
	var j = 0
	for i in range(0, len(spells)):
		var spell = get_rules().get_spell(spells[i])
		if j >= len(buttons): break
		var btn = buttons[j]
		btn.appear_anim = appear_anim
		j += 1
		btn.show_stats = show_stats
		# Padlock
		btn.enabled = enabled_filter == null or enabled_filter.call_func(spell)
		if unlocked_filter != null and unlockable_filter != null:
			btn.locked = not unlocked_filter.call_func(spell)
			btn.unlockable = unlockable_filter.call_func(spell)
		else:
			btn.locked = false
		btn.spell = spell
		btn.redraw()
	if len(buttons) != j:
		print('ERROR: Spell list updated with unequal number of spells. Had %d buttons, %d unfiltered spells' % [len(buttons), j])

func is_not_tech_spell(spell_id):
	return not get_rules().get_spell(spell_id).is_tech_spell()

var tooltip_min_open_time = 0
var tooltip_open_time = 0
func close_tooltip(force=false):
	if not force and Time.get_ticks_msec() - tooltip_open_time < tooltip_min_open_time:
		return
	var old_tooltip = tooltip
	tooltip = null
	if old_tooltip != null:
		var content = old_tooltip.label.text
		emit_signal('tooltip_closed', content)
		var disappear = old_tooltip.animation_player.get_animation('disappear')
		disappear.track_set_key_value(1, 0, old_tooltip.background.position)
		disappear.track_set_key_value(1, 1, old_tooltip.background.position - Vector2(0.0, 20.0))
		old_tooltip.animation_player.play('disappear')
		await old_tooltip.animation_player.animation_finished
		if old_tooltip != null:
			old_tooltip.get_parent().remove_child(old_tooltip)

func summon_tooltip(target, text):
	close_tooltip(true)
	tooltip = tooltip_scene.instantiate()
	tooltip.text = text
	var pos = target.get_global_rect().position
	var above = pos.y > 100
	var y = pos.y if above else (pos.y + target.size.y)
	tooltip.set_target(pos.x + target.size.x / 2, y, above)
	tooltip_open_time = Time.get_ticks_msec()
	get_node("/root").add_child(tooltip)
	tooltip.background.modulate = Color(1.0, 1.0, 1.0, 0.0)
	await tooltip.redraw().completed
	# tooltip may have been dismissed before finish redraw
	if not tooltip:
		return
	var appear = tooltip.animation_player.get_animation('appear')
	appear.track_set_key_value(1, 0, tooltip.background.position + Vector2(0.0, 20.0))
	appear.track_set_key_value(1, 1, tooltip.background.position)
	tooltip.animation_player.play('appear')
	await tooltip.animation_player.animation_finished

func summon_spell_tooltip(target, spell):
	summon_tooltip(target, "[b]%s[/b]\n%s" % [spell.get_name(), spell.get_text()])

func summon_sticky_tooltip(target, sticky):
	summon_tooltip(target, "[b]%s[/b]\n%s" % [sticky.get_name(), sticky.get_text()])

func summon_delta(target, value, color):
	var delta = delta_anim_scene.instantiate()
	var pos = target.get_global_rect().position
	var fadeup = pos.y >= 80
	delta.offset_top = pos.y - 80 if fadeup else (pos.y + target.size.y)
	delta.offset_left = pos.x + (target.size.x / 2) - 25
	get_node("/root").add_child(delta)
	delta.play_text_and_color(("+" if value > 0 else "") + str(value), color, fadeup)

func summon_confirm(text):
	var confirm = confirm_popup_scene.instantiate()
	confirm.text = text
	get_node("/root").add_child(confirm)
	return confirm

func summon_notification(text, sticky=false, on_click=null):
	scene_loader.notification.push_notification(text, sticky, on_click)

func summon_text_entry(text, default_text):
	var popup = text_entry_popup_scene.instantiate()
	popup.text = text
	popup.default_text = default_text
	get_node("/root").add_child(popup)
	return popup

func event_is_pressed(event):
	return event is InputEventMouseButton \
		and event.button_index == MOUSE_BUTTON_LEFT \
		and event.pressed

func event_is_release(event):
	return event is InputEventMouseButton \
		and event.button_index == MOUSE_BUTTON_LEFT \
		and not event.pressed

func tween(thing, to_pos, time):
	var tw = Tweener.new(get_node('/root'))
	tw.tween_to(thing, to_pos, time)
	return tw

func safe_disconnect(object, signal_, target, method):
	if object.is_connected(signal_, Callable(target, method)):
		object.disconnect(signal_, Callable(target, method))

func remove_tutorial_overlay():
	if tutorial_overlay != null && tutorial_overlay.get_parent() != null:
		tutorial_overlay.get_parent().remove_child(tutorial_overlay)
	tutorial_overlay = null
	tooltip_min_open_time = 0

func remove_backend():
	if backend != null:
		backend.free()
		backend = null

func compare_versions(a, b):
	for i in range(len(a)):
		if a[i] < b[i]:
			return -1
		elif a[i] > b[i]:
			return 1
	return 0

func string_to_version(s):
	var p = s.split('.')
	return [int(p[0]), int(p[1]), int(p[2])]

func version_to_string(v):
	return '%d.%d.%d' % [v[0], v[1], v[2]]

# Data to persist between sessions.
const save_path = 'user://saved_data.json'
const default_rules_path = 'res://data/rules.json'
var auth_uuid
var auth_pwd
var first_play
var user_name
var friend_code
var multiplayer_wins
var unsubmitted_games
var music_muted
var sfx_muted
# var rules # (declared above)

func save():
	var data = {
		'auth_uuid': auth_uuid,
		'auth_pwd': auth_pwd,
		'first_play': first_play,
		'user_name': user_name,
		'friend_code': friend_code,
		'rules': rules.back().as_json().result,
		'multiplayer_wins': multiplayer_wins,
		'unsubmitted_games': unsubmitted_games,
		'music_muted': music_muted,
		'sfx_muted': sfx_muted,
	}
	var file = File.new()
	file.open(save_path, File.WRITE)
	file.store_line(JSON.new().stringify(data))
	file.close()

func dict_has(dict, key, default):
	if dict.has(key):
		return dict[key]
	else:
		return default

func load():
	var file = File.new()
	var data
	if file.file_exists(save_path):
		file.open(save_path, File.READ)
		var test_json_conv = JSON.new()
		test_json_conv.parse(file.get_line())
		data = test_json_conv.get_data()
	else:
		print('No save data.')
		data = {}

	# Load rules from file by default.
	var rules_file = File.new()
	rules = [GameRules.new()]
	rules_file.open(default_rules_path, File.READ)
	rules[0].load_json_string(rules_file.get_as_text())
	rules_file.close()
	app_version = rules.back().get_version()

	# Default values for persisted data
	auth_uuid = dict_has(data, 'auth_uuid', null)
	auth_pwd = dict_has(data, 'auth_pwd', null)
	first_play = dict_has(data, 'first_play', true)
	user_name = dict_has(data, 'user_name', null)
	friend_code = dict_has(data, 'friend_code', null)
	multiplayer_wins = dict_has(data, 'multiplayer_wins', null)
	unsubmitted_games = dict_has(data, 'unsubmitted_games', [])
	music_muted = dict_has(data, 'music_muted', false)
	sfx_muted = dict_has(data, 'sfx_muted', false)

	# Override rules with those from saved_data if they're newer.
	var rules_json = dict_has(data, 'rules', null)
	if rules_json != null:
		var rules_saved = GameRules.new()
		rules_saved.load_json_string(JSON.stringify(rules_json))
		if compare_versions(rules.back().get_version(), rules_saved.get_version()) < 0:
			rules.append(rules_saved)

	if file.is_open():
		file.close()
