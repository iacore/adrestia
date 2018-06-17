extends "../action.gd"

const Action = preload("res://lib/action.gd")

var resources

func _init(player, resources).(Action.CHOOSE_RESOURCES, player):
  self.resources = resources
