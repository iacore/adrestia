extends Reference

var r = 0
var g = 0
var b = 0

func _init(r, g, b):
  self.r = r
  self.g = g
  self.b = b

static func empty():
  return new(0, 0, 0)

static func of_json(json):
  if json == null:
    return null
  return new(
      json["red"] if json.has("red") else 0,
      json["green"] if json.has("green") else 0,
      json["blue"] if json.has("blue") else 0)

func jsonify():
  var obj = {}
  if r: obj["red"] = r
  if g: obj["green"] = g
  if b: obj["blue"] = b
  return obj

func total():
  return r + g + b

func to_string():
  var result = ""
  if r: result += "%dR" % r
  if g: result += "%dG" % g
  if b: result += "%dB" % b
  if not result: result = "0"
  return result

func add(other):
  r += other.r
  g += other.g
  b += other.b

func subtract(other):
  r -= other.r
  g -= other.g
  b -= other.b

func subsumes(other):
  return r >= other.r and g >= other.g and b >= other.b

