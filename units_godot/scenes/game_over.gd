extends VBoxContainer

onready var timer = $Timer

func _ready():
  timer.connect("timeout", self, "timeout")

func timeout():
  get_tree().change_scene("res://scenes/title.tscn")