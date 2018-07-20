extends Control

signal buy_unit

var unit_type

onready var hbox = $HBox
onready var image = $HBox/Image
onready var unit_name = $HBox/Center/UnitName
onready var unit_width = $HBox/Center/UnitDesc/WidthDesc/UnitWidth
onready var unit_health = $HBox/Center/UnitDesc/HealthDesc/UnitHealth
onready var unit_attack = $HBox/Center/UnitDesc/AttackDesc/UnitAttack
onready var buy_button = $HBox/BuyButton

func init(unit_type_):
  unit_type = unit_type_

func _ready():
  image.texture = unit_type.image
  var unit_text = unit_type.name
  if unit_type.cost:
    unit_text += " (%s)" % unit_type.cost.to_string()
  unit_name.text = unit_text
  
  unit_width.text = str(unit_type.width)
  unit_health.text = str(unit_type.health)
  unit_attack.text = str(unit_type.attack)

func _on_BuyButton_pressed():
  emit_signal("buy_unit")
