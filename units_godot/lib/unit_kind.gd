extends Reference

const Colour = preload("res://lib/colour.gd")
const Resources = preload("res://lib/resources.gd")

var name
var colour
var health
var width
var attack
var cost
var font
var image

func _init(name, colour, health, width, attack, cost, font=null):
  self.name = name
  self.colour = colour
  self.health = health
  self.width = width
  self.attack = attack
  self.cost = cost
  self.font = font

static func of_json(json):
  for i in range(json["attack"].size()):
    json["attack"][i] = int(json["attack"][i])
  var result = new(
      json["name"],
      Colour.of_json(json["colour"]),
      int(json["health"]),
      int(json["width"]),
      json["attack"],
      Resources.of_json(json["cost"]),
      Resources.of_json(json["font"]) if json.has("font") else null
    )
  result.image = load('res://art/%s' % json['image']) if json.has('image') else load('res://art/unknown_unit.png')
  return result
