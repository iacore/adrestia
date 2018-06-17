extends Reference

const Resources = preload("res://lib/resources.gd")

var resources = Resources.new(0,0,0)
var resource_gain = Resources.new(0,0,0)
var units = {} # {int: Unit}
var next_unit_id = 0

func add_unit(unit):
  units[next_unit_id] = unit
  next_unit_id += 1
