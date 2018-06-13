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

func total():
  return r + g + b

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
