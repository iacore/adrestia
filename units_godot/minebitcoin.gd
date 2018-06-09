extends Panel

var bitcoins = 0

func _ready():
	get_node("Button").connect("pressed", self, "_on_button_pressed")

func _on_button_pressed():
	bitcoins += 1
	get_node("Label").text = "%d bitcoins" % bitcoins