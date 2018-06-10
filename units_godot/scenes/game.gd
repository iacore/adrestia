extends VBoxContainer

onready var r_label = $Toolbar/R
onready var g_label = $Toolbar/G
onready var b_label = $Toolbar/B
onready var g = get_node("/root/global")

func _ready():
	g.advance_turn()
	r_label.text = str(g.players[0].resources.r)
	g_label.text = str(g.players[0].resources.g)
	b_label.text = str(g.players[0].resources.b)