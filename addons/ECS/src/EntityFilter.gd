extends RefCounted

class_name EntityFilter


## Class used to filter entities with valid signature.[br]
## All filtered entities goes to [code]valid_entities[/code]

## Emmited after new entity was added to [code]valid_entities[/code]
signal entity_added(entity)
## Emmited after entity was removed from [code]valid_entities[/code]
signal entity_removed(entity)

## Emmited after an filter was registered in [code]ECS[/code]
signal was_registered
## Emmited before an filter will be unregistered in [code]ECS[/code]
signal pre_unregister

## Array of all entities, which signature matches filter's signature[br]
## Usually there is no reason to change it manually
var valid_entities : Array[Entity] = [] 
## If true, the filter is registered in [code]ECS[/code].[br]
## Usually there is no reason to change it manually
var registered : bool = false
## Signature for filtering valid entities
var entity_signature : Dictionary 



func _init(signature:Dictionary): # Filter registration lies on it owner
	entity_signature = signature.duplicate(true)

## Only for use by ECS autoload[br]
## Adds [code]entity[/code] to the [code]valid_entities[/code]
func add_entity(entity:Entity): 
	valid_entities.append(entity)
	
	entity_added.emit(entity)

## Only for use by ECS autoload[br]
## Removes [code]entity[/code] from the [code]valid_entities[/code]
func remove_entity(entity:Entity):
	valid_entities.erase(entity)
	
	entity_removed.emit(entity)
