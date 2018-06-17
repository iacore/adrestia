extends Control

var unit_type

onready var hbox = $HBox
onready var image = $HBox/Image
onready var unit_name = $HBox/Center/UnitName
onready var unit_desc = $HBox/Center/UnitDesc
onready var buy_button = $HBox/BuyButton

func init(unit_type_):
  unit_type = unit_type_

func _ready():
  image.texture = unit_type.image
  var unit_text = unit_type.name
  if unit_type.cost:
    unit_text += " (%s)" % unit_type.cost.to_string()
  unit_name.text = unit_text
  
  var desc_parts = []
  desc_parts.append("W%d" % unit_type.width)
  desc_parts.append("H%d" % unit_type.health)
  if unit_type.attack: desc_parts.append("A%s" % str(unit_type.attack))
  unit_desc.text = PoolStringArray(desc_parts).join(" / ")