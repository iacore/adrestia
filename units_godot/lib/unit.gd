extends Reference

var kind
var health
var polygon = null

func _init(kind):
  self.kind = kind
  self.health = kind.health
