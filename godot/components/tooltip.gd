extends Control

signal redrawn

@onready var g = get_node('/root/global')

@onready var background = $background
@onready var ninepatch = $background/nine_patch_rect
@onready var label = $background/nine_patch_rect/rich_text_label
@onready var triangle = $background/triangle
@onready var animation_player = $animation_player

# TODO: jim: I tried to make tooltips editable in the editor but couldn't
# figure out how to make them update their appearance.
@export var text = '': set = set_text
@export var x: int = 0
@export var y: int = 0
var point_down = true

# reasoning: triangle height is 20
# + 5 for border thickness
# + 2 for margin of error
const triangle_shift = 27

# TODO: jim: autodetect this
const line_height = 26

func _ready():
	pass

func _gui_event(event):
	if g.event_is_pressed(event):
		g.close_tooltip()

func set_text(text_):
	text = text_

func set_target(x_, y_, point_down_=true):
	x = x_
	y = y_
	point_down = point_down_

func redraw():
	if triangle == null: return
	if label == null: return

	label.text = text
	var margin = label.offset_top + ninepatch.offset_top + 2

	var triangle_size = triangle.size
	var desired_margin_left = x - floor(triangle_size.x / 2)
	triangle.offset_left = min(get_viewport_rect().size.x - triangle_size.x - 25, max(25, desired_margin_left))
	triangle.offset_right = triangle.offset_left + triangle_size.x
	if point_down:
		triangle.anchor_top = 1
		triangle.anchor_bottom = 1
		triangle.offset_top = -triangle_shift
		triangle.scale.y = 1
	else:
		triangle.anchor_top = 0
		triangle.anchor_bottom = 0
		triangle.offset_top = triangle_shift
		triangle.scale.y = -1
	triangle.offset_bottom = triangle.offset_top + triangle_size.y

	# XTODO: charles: This doesn't work if any lines wrap. We want to use
	# get_visible_line_count() instead, but there's a bug where it always returns
	# 0, so we cant.
	# jim: Looks like we have to wait a frame so that the RichTextLabel reflows
	# its text. ... though in addition to that, it seems that [get_line_count]
	# ONLY counts lines from newline characters, whereas [get_visible_line_count]
	# ONLY counts lines from wrapping... so here we go.
	# This will probably break when Godot is fixed.

	# Try to set tooltip text for three frames, seeing if # of computed lines
	# changes at each frame.
	var old_lines = null
	for _unused in range(3):
		var lines = label.get_line_count() + max(label.get_visible_line_count(), 1) - 1
		if lines == old_lines:
			break
		old_lines = lines
		var height = lines * line_height + margin * 2
		if point_down:
			background.offset_top = y - height
			background.offset_bottom = y
		else:
			background.offset_top = y
			background.offset_bottom = y + height
		if is_inside_tree(): await get_tree().idle_frame
	emit_signal('redrawn')
