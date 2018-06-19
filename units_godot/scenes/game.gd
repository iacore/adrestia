extends VBoxContainer

var unit_buy_bar = preload('res://components/unit_buy_bar.tscn')
var BuildUnit = preload('res://lib/actions/build_unit.gd')
var Colour = preload('res://lib/colour.gd')

onready var r_label = $Toolbar/R
onready var g_label = $Toolbar/G
onready var b_label = $Toolbar/B
onready var EndTurnButton = $Toolbar/EndTurnButton
onready var UnitList = $ScrollContainer/UnitList
onready var Armies = $MarginContainer/Armies
onready var g = get_node("/root/global")
onready var units = get_node("/root/UnitKinds").units
var unit_bars = {}

static func unit_fits(occupied, blocks, x, y):
  for xy in blocks:
    if occupied.has([xy[0]+x, xy[1]+y]):
      return false
  return true

class SortUnitsByWidth:
  static func sort(a, b):
    return (a.kind.width > b.kind.width)

func update_ui():
  var view = g.man.get_view()

  r_label.text = str(view.players[0].resources.r)
  g_label.text = str(view.players[0].resources.g)
  b_label.text = str(view.players[0].resources.b)
  for unit in unit_bars:
    unit_bars[unit].buy_button.disabled = !view.players[0].resources.subsumes(units[unit].cost)
  
  # Unit packing
  for pid in range(view.players.size()):
    var player = view.players[pid]

    var occupied = {}
    var packing_data = []
    var goal_aspect = 2.0 # Goal aspect ratio. >1 is wider.
    var units = [] + player.units.values()
    units.sort_custom(SortUnitsByWidth, "sort")
    for unit in units:
      var flat_blocks = unit.kind.tiles
      var blocks = []
      for i in range(flat_blocks.size() / 2):
        blocks.append([flat_blocks[2 * i], flat_blocks[2 * i + 1]])

      # Find a place to put this unit.
      var result_x; var result_y
      var x = 0
      var y = 0
      var done = false
      while not done:
        if x == 0 or x <= y * goal_aspect:
          # Add a column
          for i in range(0, y):
            if unit_fits(occupied, blocks, x, i):
              done = true
              result_x = x
              result_y = i
              break
          if not done:
            x += 1
        else:
          # Add a row
          for i in range(0, x):
            if unit_fits(occupied, blocks, i, y):
              done = true
              result_x = i
              result_y = y
              break
          if not done:
            y += 1

      for xy in blocks:
        occupied[[xy[0] + result_x, xy[1] + result_y]] = true

      packing_data.append([Colour.to_color(unit.kind.colour), [result_x, result_y], flat_blocks])
      x += 1
    Armies.get_child(1 - pid).data = packing_data

func _ready():
  for unit in units:
    if units[unit].cost != null:
      var bar = unit_buy_bar.instance()
      bar.init(units[unit]);
      unit_bars[unit] = bar
      bar.connect("buy_unit", self, "_on_buy_unit", [unit])
      UnitList.add_child(bar)
  EndTurnButton.connect("button_down", self, "_on_EndTurnButton_pressed")
  update_ui()

func _on_EndTurnButton_pressed():
  g.man.simulate_battle(self, '_on_simulate_battle_complete')

func _on_simulate_battle_complete(result):
  # TODO: charles: display result in some way
  if g.man.get_view().is_game_over():
    get_tree().change_scene("res://scenes/game_over.tscn")
  else:
    update_ui()

func _on_buy_unit(unit):
  # TODO: charles: Don't actually make moves until the end of the turn;
  # instead, keep local list of units and draw army with [current units] plus
  # [queued units]. This will allow us to implement undo, and potentially
  # display queued units in a different way (e.g. faded)
  g.man.perform_action(BuildUnit.new(0, units[unit]))
  update_ui()
