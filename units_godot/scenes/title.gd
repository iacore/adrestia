extends Node

func _ready():
	get_tree().set_auto_accept_quit(true)
	get_tree().set_quit_on_go_back(true)

func _on_button_play_pressed():
	get_tree().change_scene("res://scenes/resource_select.tscn")
	get_tree().set_auto_accept_quit(false)
	get_tree().set_quit_on_go_back(false)