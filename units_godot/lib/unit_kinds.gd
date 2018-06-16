extends Node

const UnitKind = preload("res://lib/unit_kind.gd")
var units = {}

static func load_units():
  var file = File.new()
  file.open("res://data/units.json", file.READ)
  var dict = JSON.parse(file.get_as_text()).result
  file.close()
  for key in dict.keys():
    dict[key] = UnitKind.of_json(dict[key])
  return dict

func _ready():
  units = load_units()
