extends "../action.gd"

const Action = preload("res://lib/action.gd")

var kind

func _init(player, kind).(Action.BUILD_UNIT, player):
  self.kind = kind
