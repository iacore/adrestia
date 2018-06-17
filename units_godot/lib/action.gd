extends Reference

enum Type {
  CHOOSE_RESOURCES,
  BUILD_UNIT,
}

var type
var player

func _init(type, player):
  self.type = type
  self.player = player
