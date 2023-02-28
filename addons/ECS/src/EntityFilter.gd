extends RefCounted

class_name EntityFilter

signal entity_added(entity)
signal entity_removed(entity)

signal was_registered
signal pre_unregister


var valid_entities : Array[Entity] = [] # for changing by ECS
var registered : bool = false
var entity_signature : Dictionary 



func _init(signature:Dictionary): # Filter registration lies on it owner
	entity_signature = signature.duplicate(true)


func add_entity(entity:Entity): # Only for use in ECS autoload!
	valid_entities.append(entity)
	
	entity_added.emit(entity)


func remove_entity(entity:Entity): # Only for use in ECS autoload!
	valid_entities.erase(entity)
	
	entity_removed.emit(entity)
