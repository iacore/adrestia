extends Control

var unit_kind

onready var hbox = $HBox
onready var image = $HBox/Image
onready var unit_name = $HBox/UnitName
onready var buy_button = $HBox/BuyButton

func _ready():
  var texture = load('res://art/unknown_unit.png')
  image.texture = texture
  image.rect_size = Vector2(hbox.rect_size.y, hbox.rect_size.y)
  image.update()
  rect_size = hbox.rect_size
  rect_min_size = hbox.rect_size
  update()