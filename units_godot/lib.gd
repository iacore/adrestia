extends Node

class Resource:
	var r = 0
	var g = 0
	var b = 0
	
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

class Player:
	var resources = Resource.new()
	var resource_gain = Resource.new()