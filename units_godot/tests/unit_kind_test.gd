extends SceneTree

const UnitKinds = preload("res://lib/unit_kinds.gd")

func _init():
  var units = UnitKinds.load_units()
  print(units.keys())
  quit()
