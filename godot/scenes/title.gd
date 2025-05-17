extends Node

@onready var g = get_node('/root/global')
@onready var avatar_profile = $ui/avatar_profile
@onready var play_button = $ui/play_button
@onready var match_history_button = $ui/match_history_button
@onready var settings_button = $ui/settings_button
@onready var friends_button = $ui/friends_button
@onready var animation_player = $animation_player

const TutorialOverlay = preload('res://components/tutorial_overlay.tscn')
const TutorialBackend = preload('res://backends/tutorial.gd')
const OnlineBackend = preload('res://backends/online.gd')

func _ready():
	get_tree().set_auto_accept_quit(true)
	get_tree().set_quit_on_go_back(true)
	g.remove_tutorial_overlay()
	g.remove_backend();
	play_button.connect('pressed', Callable(self, 'on_play_button_pressed'))
	match_history_button.connect('pressed', Callable(self, 'on_match_history_button_pressed'))
	settings_button.connect('pressed', Callable(self, 'on_settings_button_pressed'))
	friends_button.connect('pressed', Callable(self, 'on_friends_button_pressed'))
	if not g.loaded:
		g.loaded = true
		initialize()
		animation_player.play('fade_in')
	g.sound.set_music('title')
	g.network.register_handler('push_active_games', funcref(self, 'on_push_active_games'))
	g.network.register_handlers(self, 'on_connected', 'on_disconnected', 'on_out_of_date')
	g.network.get_stats(funcref(self, 'on_get_stats'))

# TODO: jim: Retrieve your own profile in a more principled way
func on_get_stats(response):
	if response.has('wins'):
		g.multiplayer_wins = response.wins
		g.save()
		on_connected()

func initialize():
	print('User data dir is %s' % [OS.get_user_data_dir()])
	# For server development on desktop.
	g.load()

func on_connected():
	avatar_profile.name_label.text = g.user_name
	if g.friend_code:
		avatar_profile.fc_label.text = 'FC: %s' % [g.friend_code]
	if g.multiplayer_wins:
		avatar_profile.wins_label.text = 'Online wins: %d' % [g.multiplayer_wins]
	avatar_profile.online_label.text = 'Online'

func on_disconnected():
	avatar_profile.name_label.text = g.user_name
	if g.friend_code:
		avatar_profile.fc_label.text = 'FC: %s' % [g.friend_code]
	if g.multiplayer_wins:
		avatar_profile.wins_label.text = 'Online wins: %d' % [g.multiplayer_wins]
	avatar_profile.online_label.text = 'Offline'

func on_out_of_date():
	avatar_profile.name_label.text = g.user_name
	if g.friend_code:
		avatar_profile.fc_label.text = 'FC: %s' % [g.friend_code]
	if g.multiplayer_wins:
		avatar_profile.wins_label.text = 'Online wins: %d' % [g.multiplayer_wins]
	avatar_profile.online_label.text = 'Out-of-date client'

func on_push_active_games(response):
	print(response)
	if await g.summon_confirm('Would you like to reconnect to your active game?').popup_closed:
		g.backend = OnlineBackend.new(g)
		g.backend.reconnect(response)
		g.scene_loader.goto_scene('game')
	else:
		g.network.abort_game(response.updates[0].game_uid, funcref(g.network, 'discard'))
	return true

func on_play_button_pressed():
	g.sound.play_sound('button')
	if g.first_play:
		g.first_play = false
		g.save()
		if await g.summon_confirm('It looks like this is your first time playing. Play the tutorial?').popup_closed == true:
			on_tutorial_button_pressed()
			return
	g.scene_loader.goto_scene('game_mode_select')

func on_match_history_button_pressed():
	g.sound.play_sound('button')
	g.scene_loader.goto_scene('match_history')

func on_settings_button_pressed():
	g.sound.play_sound('button')
	g.scene_loader.goto_scene('settings')

func on_friends_button_pressed():
	g.sound.play_sound('button')
	g.scene_loader.goto_scene('friends')

func on_tutorial_button_pressed():
	g.sound.play_sound('button')
	g.backend = TutorialBackend.new(g)
	var tutorial_overlay = TutorialOverlay.instantiate()
	get_node('/root').add_child(tutorial_overlay)
	tutorial_overlay.play_tutorial()
	g.scene_loader.goto_scene('game_book_select')
