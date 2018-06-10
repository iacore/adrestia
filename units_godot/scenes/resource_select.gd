extends HBoxContainer

var lib = preload("res://lib.gd")

onready var r_button = $RCounter/Button
onready var r_label = $RCounter/Label
onready var g_button = $GCounter/Button
onready var g_label = $GCounter/Label
onready var b_button = $BCounter/Button
onready var b_label = $BCounter/Label
onready var reset_button = get_node("../ResetButton")
onready var begin_button = get_node("../../BeginButton")
onready var g = get_node("/root/global")

var resources = lib.Resource.new()

func _ready():
	r_button.connect("button_down", self, "_on_r_pressed")
	g_button.connect("button_down", self, "_on_g_pressed")
	b_button.connect("button_down", self, "_on_b_pressed")
	reset_button.connect("button_down", self, "_on_reset_pressed")
	begin_button.connect("button_down", self, "_on_begin_pressed")

func update_labels():
	r_label.text = str(resources.r)
	g_label.text = str(resources.g)
	b_label.text = str(resources.b)

func _on_r_pressed():
	if resources.total() < 7:
		resources.r += 1
		update_labels()

func _on_g_pressed():
	if resources.total() < 7:
		resources.g += 1
		update_labels()

func _on_b_pressed():
	if resources.total() < 7:
		resources.b += 1
		update_labels()
	
func _on_reset_pressed():
	resources.r = 0
	resources.g = 0
	resources.b = 0
	update_labels()
	
func _on_begin_pressed():
	if resources.total() == 7:
		g.players[0].resource_gain = resources
		get_tree().change_scene("res://scenes/game.tscn")