extends Node

# We use this instead of [get_tree().change_scene()] for the sick scene-loading
# transition.
# How it works:
# - Scene change is requested
# - A giant hexagon starts to roll into the screen. In parallel, we start
# loading the new scene's resources.
# - The giant hexagon covers the screen. During this time, we finish loading
# the new scene if there's anything left to load.
# - The old scene is deleted and the new scene is inserted into the tree.
# - The giant hexagon rolls off the screen, revealing the new scene.

# See
# http://docs.godotengine.org/en/latest/tutorials/io/background_loading.html

@onready var g = get_node('/root/global')
@onready var root = get_tree().get_root()
const transition_scene = preload('res://components/transition_bg.tscn')
const notification_scene = preload('res://components/notification.tscn')
var scene_holder
var transition
var notification
var loader
var current_scene
var playing_backwards = false

func _ready():
	transition = transition_scene.instantiate()
	notification = notification_scene.instantiate()
	current_scene = root.get_child(root.get_child_count() - 1)
	scene_holder = Node.new()
	add_child(scene_holder)
	call_deferred('possess_initial_scene')

func possess_initial_scene():
	root.remove_child(current_scene)
	scene_holder.add_child(current_scene)
	current_scene.add_child(notification)

func _process(time):
	# For scene loader.
	if loader == null:
		set_process(false)
		return

	# Busy loop for a frame (maybe this is bad)
	var t = Time.get_ticks_msec()
	while Time.get_ticks_msec() < t + 16:
		var err = loader.poll()
		if err == ERR_FILE_EOF: # Load finished.
			# Don't advance scene until animation is done.
			var resource = loader.get_resource()
			loader = null
			set_new_scene(resource)
			break
		elif err == OK:
			update_progress()
		else:
			print('FAILURE: Could not load new scene')
			loader = null
			break

func goto_scene(scene_name, backwards=false):
	if transition and transition.animation_player and transition.animation_player.is_playing():
		await transition.animation_player.animation_finished
	g.close_tooltip()
	loader = ResourceLoader.load_threaded_request('res://scenes/%s.tscn' % [scene_name])
	set_process(true)
	transition.visible = true
	root.add_child(transition)
	transition.on_resize()
	playing_backwards = backwards
	if not backwards:
		transition.animation_player.play('slide_in')
	else:
		transition.animation_player.play_backwards('slide_out')
	g.sound.play_sound('screen_transition')

func update_progress():
	var progress = float(loader.get_stage()) / loader.get_stage_count()

func set_new_scene(scene_resource):
	if transition and transition.animation_player and transition.animation_player.is_playing():
		await transition.animation_player.animation_finished

	current_scene.queue_free()
	current_scene = scene_resource.instantiate()
	scene_holder.add_child(current_scene)
	notification.get_parent().remove_child(notification)
	current_scene.add_child(notification)

	if not playing_backwards:
		transition.animation_player.play('slide_out')
	else:
		transition.animation_player.play_backwards('slide_in')
	await transition.animation_player.animation_finished
	root.remove_child(transition)
