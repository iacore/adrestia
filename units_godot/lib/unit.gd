extends Node

class Unit:
	var kind
	var health
	
	func _init(kind):
		self.kind = kind
		self.health = kind.health
