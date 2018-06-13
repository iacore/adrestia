extends Node

const Colour = preload("res://lib/colour.gd")
const Resources = preload("res://lib/resources.gd")
const UnitKind = preload("res://lib/unit_kind.gd")

# TODO: jim: Read this from an input file on both the frontend and the backend.
var units = {
  'general': UnitKind.new('General', Colour.BLACK, 5, 1, [1], null),
  'wall': UnitKind.new('Wall', Colour.GREEN, 1, 1, [], Resources.new(0,1,0)),
  'turret': UnitKind.new('Turret', Colour.GREEN, 1, 2, [1], Resources.new(0,2,0)),
}
