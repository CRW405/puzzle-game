## Define element id, name, color, and assign behaviours
extends RefCounted
class_name ElementRegistry

enum {
	#...
}


static func get_color() -> Color:
	pass


static func get_name() -> String:
	pass


##  matches <element>behaviour to <element>
static func get_behaviour():
	pass
