extends VBoxContainer

var unit_buy_bar = preload('res://components/unit_buy_bar.tscn')

onready var r_label = $Toolbar/R
onready var g_label = $Toolbar/G
onready var b_label = $Toolbar/B
onready var EndTurnButton = $Toolbar/EndTurnButton
onready var UnitList = $ScrollContainer/UnitList
onready var g = get_node("/root/global")
onready var units = get_node("/root/UnitKinds").units
var unit_bars = {}

func update_ui():
  r_label.text = str(g.players[0].resources.r)
  g_label.text = str(g.players[0].resources.g)
  b_label.text = str(g.players[0].resources.b)
  for unit in unit_bars:
    unit_bars[unit].buy_button.disabled = !g.players[0].resources.subsumes(units[unit].cost)

func _ready():
  print(units.size())
  for unit in units:
    if units[unit].cost != null:
      var bar = unit_buy_bar.instance()
      bar.show()
      unit_bars[unit] = bar
      UnitList.add_child(bar)
  EndTurnButton.connect("button_down", self, "_on_EndTurnButton_pressed")
  g.start_game()
  update_ui()

func _on_EndTurnButton_pressed():
  g.advance_turn()
  update_ui()
