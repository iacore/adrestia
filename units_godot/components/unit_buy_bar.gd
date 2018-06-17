extends Control

var unit_type

onready var hbox = $HBox
onready var image = $HBox/Image
onready var unit_name = $HBox/UnitName
onready var buy_button = $HBox/BuyButton

func init(unit_type_):
  unit_type = unit_type_

func _ready():
  image.texture = unit_type.image
  unit_name.text = unit_type.name