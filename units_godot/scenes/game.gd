extends VBoxContainer

onready var r_label = $Toolbar/R
onready var g_label = $Toolbar/G
onready var b_label = $Toolbar/B
onready var EndTurnButton = $Toolbar/EndTurnButton
onready var g = get_node("/root/global")

func update_ui():
  r_label.text = str(g.players[0].resources.r)
  g_label.text = str(g.players[0].resources.g)
  b_label.text = str(g.players[0].resources.b)

func _ready():
  EndTurnButton.connect("button_down", self, "_on_EndTurnButton_pressed")
  g.start_game()
  update_ui()

func _on_EndTurnButton_pressed():
  g.advance_turn()
  update_ui()