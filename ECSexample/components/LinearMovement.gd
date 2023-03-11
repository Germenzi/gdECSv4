extends RefCounted

class_name C_LinearMovement

const COMPONENT_TYPE = "C_LinearMovement"

var speed : float
var direction : Vector2


func _init(ispeed:float, idir:Vector2):
	speed = ispeed
	direction = idir
