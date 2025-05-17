extends Node

@onready var g = get_node('/root/global')

@onready var back_button = $ui/back_button

func _ready():
	back_button.connect('pressed', Callable(self, 'on_back_button_pressed'))
	get_tree().set_auto_accept_quit(false)

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		self.call_deferred('on_back_button_pressed')

func on_back_button_pressed():
	g.sound.play_sound('button')
	g.scene_loader.goto_scene('settings', true)
