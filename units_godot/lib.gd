extends Node

# TODO: jim: Split this file up.

enum Colour {
	BLACK,
	RED,
	GREEN,
	BLUE,
	WHITE,
}

class Resources:
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

class UnitKind:
	var name
	var colour
	var health
	var width
	var attack
	var cost
	
	func _init(name, colour, health, width, attack, cost):
		self.name = name
		self.colour = colour
		self.health = health
		self.width = width
		self.attack = attack
		self.cost = cost

class Unit:
	var kind
	var health
	
	func _init(kind):
		self.kind = kind
		self.health = kind.health

# TODO: jim: Read this from an input file on both the frontend and the backend.
var units = {
	'general': UnitKind.new('General', Colour.BLACK, 5, 1, [1], null),
	'wall': UnitKind.new('Wall', Colour.GREEN, 1, 1, [], Resources.new(0,1,0)),
	'turret': UnitKind.new('Turret', Colour.GREEN, 1, 2, [1], Resources.new(0,2,0)),
}

class Player:
	var resources = Resources.new(0,0,0)
	var resource_gain = Resources.new(0,0,0)
	var units = [] # [Unit]